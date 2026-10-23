-- world_watch: pure logic of the world watcher (libexec/dune-world-watch does the I/O). Reads the map server's log
-- for sandworm attacks and sandstorms, whispers an omen to the online players when a worm goes for a player, their
-- vehicle or their thumper, and keeps a tally of each play session (first broker connection until CHRONICLE_GAP
-- seconds with none) that becomes the session chronicle: per-character gains, quests completed, worms, storms and GM
-- bridge commands, handed to the operator's assistant as an llmsend note. State machine over (state, input, now,
-- config) with an injected clock and random number source.
local cjson = require("cjson")
local M = {}

local SWITCH = { ["0"] = false, off = false, ["false"] = false, no = false, ["1"] = true, on = true, ["true"] = true, yes = true }
local SWITCHES = { { "omens", "OMENS" }, { "chronicle", "CHRONICLE" } }
local SETTINGS = {
	{ "worm_cooldown", "OMEN_COOLDOWN", 60, 0 }, { "storm_cooldown", "STORM_OMEN_COOLDOWN", 1800, 0 },
	{ "session_gap", "CHRONICLE_GAP", 900, 1 }, { "session_min", "CHRONICLE_MIN", 600, 0 },
	{ "poll", "WATCH_POLL", 2, 1 }, { "roster_every", "WATCH_ROSTER", 60, 1 },
}
local MAX_FROM = 32

-- Parse and validate the settings; get(name) returns an environment value or nil. Returns config or nil, message.
function M.parse_config(get)
	local c = {}
	for _, s in ipairs(SWITCHES) do
		local v = get("DUNE_" .. s[2])
		if v == nil or v == "" then c[s[1]] = true
		elseif SWITCH[v:lower()] ~= nil then c[s[1]] = SWITCH[v:lower()]
		else return nil, s[2] .. " must be 1 or 0 (on/off), got " .. v end
	end
	for _, s in ipairs(SETTINGS) do
		local field, name, default, min = s[1], s[2], s[3], s[4]
		local v = get("DUNE_" .. name)
		if v == nil or v == "" then c[field] = default
		else
			local n = v:match("^%d+$") and tonumber(v)
			if not n or n < min then return nil, string.format("%s must be a whole number >= %d, got %s", name, min, v) end
			c[field] = n
		end
	end
	local from = get("DUNE_OMEN_FROM")
	if from == nil or from == "" then from = "Thufir" end
	if #from > MAX_FROM then return nil, string.format("OMEN_FROM must be at most %d characters", MAX_FROM) end
	c.from = from
	return c
end

-- Log lines ----------------------------------------------------------------------------------------------------

-- A worm about to strike logs "hide N seconds before teleporting to attack" once per attack, with its target's
-- threat type; its other Attack-mode lines (is hidden, animations) repeat and are ignored. Storms log one request
-- per spawn, naming the region in brackets.
function M.parse_line(line)
	if line:find("ESandwormSteeringMode::Attack", 1, true) then
		local lead = line:match("%] hide ([%d%.]+) seconds before teleporting to attack")
		if not lead then return nil end
		local id = tonumber(line:match("ID: (%d+)"))
		local target = line:match("EThreatBlobType::(%w+)")
		if not (id and target) then return nil end
		return { kind = "worm", worm = id, target = target, enraged = line:match("Enraged:1") ~= nil, lead = math.floor(tonumber(lead) + 0.5) }
	end
	local region = line:match("LogSandStormManager: Log: Requested a Sandstorm auto%-spawn on %[(%w+)%]")
	if region then return { kind = "storm", region = region } end
	return nil
end

-- Threat types (EThreatBlobType in the 1.5 server) a player is behind, by omen kind; the rest (wrecks, spice, NPCs,
-- areas) get none. An unknown future type gets none either.
local TARGETS = { Character = "character", Group = "character", Vehicle = "vehicle", Thumper = "thumper", UniqueThumper = "thumper",
	Area = false, Default = false, DesertWreck = false, ValuableDesertWreck = false, Npc = false, Spice = false }
function M.omen_target(t) return TARGETS[t] end

-- "HaggaBasin" -> "Hagga Basin".
function M.region_name(r) return (r:gsub("(%l)(%u)", "%1 %2")) end

-- Omen table: lines of `kind<TAB>text` (data/omens.tsv), # comments and blank lines skipped. Storm texts may use
-- {region}. Returns {kind = {texts}} or nil, message naming the line.
local KINDS = { ["worm-character"] = true, ["worm-vehicle"] = true, ["worm-thumper"] = true, storm = true }
function M.parse_omens(text)
	local t, n = {}, 0
	for line in (text .. "\n"):gmatch("([^\n]*)\n") do
		n = n + 1
		if line ~= "" and not line:match("^#") then
			local kind, body = line:match("^([^\t]+)\t(.*)$")
			if not kind then return nil, string.format("line %d: expected kind<TAB>text", n) end
			if not KINDS[kind] then return nil, string.format("line %d: unknown kind %s", n, kind) end
			if body:match("^%s*$") then return nil, string.format("line %d: no text", n) end
			t[kind] = t[kind] or {}
			t[kind][#t[kind] + 1] = body
		end
	end
	return t
end

-- State --------------------------------------------------------------------------------------------------------

function M.new_state() return { last_omen = {}, worms_seen = {} } end

function M.encode(st) return cjson.encode(st) end

function M.decode(text)
	local ok, t = pcall(cjson.decode, text or "")
	if not ok or type(t) ~= "table" then return M.new_state() end
	t.last_omen = type(t.last_omen) == "table" and t.last_omen or {}
	t.worms_seen = type(t.worms_seen) == "table" and t.worms_seen or {}
	if type(t.session) ~= "table" then t.session = nil end
	return t
end

local function new_session(now)
	return { start = now, last_seen = now, players = {}, worms = {}, storms = {}, omens = 0 }
end

local function bump(t, k) t[k] = (t[k] or 0) + 1 end

-- One log event. Returns state and the whispers to send ({to, text}); online = names of the online characters.
-- Nothing is tallied or sent outside a session. A worm's repeated attack line within OMEN_COOLDOWN is the same
-- attack; omens of one kind (worm, storm) are at most one per its cooldown, and every recipient gets the same line.
function M.on_event(st, ev, now, cfg, omens, rng, online)
	local out = {}
	local s = st.session
	if not s then return st, out end
	local kind
	if ev.kind == "worm" then
		local key = tostring(ev.worm)
		local seen = st.worms_seen[key]
		if seen and now - seen < cfg.worm_cooldown then return st, out end
		st.worms_seen[key] = now
		bump(s.worms, ev.target)
		local target = M.omen_target(ev.target)
		if target then kind = "worm-" .. target end
	elseif ev.kind == "storm" then
		bump(s.storms, ev.region)
		kind = "storm"
	end
	if not (kind and cfg.omens and omens[kind] and #omens[kind] > 0 and #online > 0) then return st, out end
	local family = ev.kind
	local cooldown = family == "worm" and cfg.worm_cooldown or cfg.storm_cooldown
	local last = st.last_omen[family]
	if last and now - last < cooldown then return st, out end
	local list = omens[kind]
	local text = list[rng(#list)]
	if ev.region then text = text:gsub("{region}", (M.region_name(ev.region):gsub("%%", "%%%%"))) end
	for i, name in ipairs(online) do out[i] = { to = name, text = text } end
	st.last_omen[family] = now
	s.omens = s.omens + 1
	return st, out
end

-- Broker connections from players. Opens a session on the first one; closes it after session_gap seconds with
-- none. Returns state and the finished session when it is worth a chronicle (at least session_min long, with a
-- character seen online), else nil.
function M.on_presence(st, connections, now, cfg)
	local s = st.session
	if connections > 0 then
		if not s then st.session = new_session(now) else s.last_seen = now end
		return st, nil
	end
	if not s or now - s.last_seen < cfg.session_gap then return st, nil end
	st.session = nil
	st.worms_seen = {}
	s.finish = s.last_seen
	if s.finish - s.start < cfg.session_min or next(s.players) == nil then return st, nil end
	return st, s
end

local function snapshot(c)
	return { name = c.name, xp_total = c.xp_total or 0, intel_points = c.intel_points or 0, skill_points_total = c.skill_points_total or 0 }
end

-- The character list (dune-character list --json) and completed quests by character id. Each character's first
-- sighting online is its baseline (values and completed quests); later sightings refresh only its latest values.
function M.on_roster(st, roster, quests, now)
	local s = st.session
	if not s then return st end
	for _, c in ipairs(roster) do
		local key = tostring(c.id)
		local p = s.players[key]
		if c.online and not p then
			local q = {}
			for id in pairs(quests[c.id] or {}) do q[id] = true end
			s.players[key] = { first = snapshot(c), last = snapshot(c), quests = q, seen = now }
		elseif p then
			p.last = snapshot(c)
		end
	end
	return st
end

-- Chronicle ----------------------------------------------------------------------------------------------------

local function iso(t) return os.date("!%Y-%m-%dT%H:%M:%SZ", t) end

-- GM bridge log lines (`<UTC time> <FLS id> <character> allowed|denied: <command>`) between from and to (epoch
-- seconds, inclusive). Other lines (starts, broker errors, note deliveries) are skipped.
function M.parse_bridge_log(text, from, to)
	local lo, hi, out = iso(from), iso(to), {}
	for line in (text or ""):gmatch("[^\n]+") do
		local t, name, verdict, cmd = line:match("^(%d%d%d%d%-%d%d%-%d%dT%d%d:%d%d:%d%dZ) %x+ (.-) (%a+): (.*)$")
		if t and (verdict == "allowed" or verdict == "denied") and t >= lo and t <= hi then
			out[#out + 1] = { time = t, name = name, allowed = verdict == "allowed", command = cmd }
		end
	end
	return out
end

-- Facts of a finished session: final_quests = completed quests by character id read at its end.
function M.chronicle(s, final_quests, commands)
	local players = {}
	for key, p in pairs(s.players) do
		local done = {}
		for id in pairs(final_quests[tonumber(key)] or {}) do
			if not p.quests[id] then done[#done + 1] = id end
		end
		table.sort(done)
		players[#players + 1] = { name = p.last.name or p.first.name, xp_gained = p.last.xp_total - p.first.xp_total,
			intel_gained = p.last.intel_points - p.first.intel_points,
			skill_points_gained = p.last.skill_points_total - p.first.skill_points_total, quests = done }
	end
	table.sort(players, function(a, b) return a.name < b.name end)
	return { start = s.start, finish = s.finish, minutes = math.floor((s.finish - s.start) / 60 + 0.5), players = players,
		worms = s.worms, storms = s.storms, omens = s.omens, commands = commands }
end

local function sorted_keys(t)
	local k = {}
	for key in pairs(t) do k[#k + 1] = key end
	table.sort(k)
	return k
end

local function signed(n) return (n >= 0 and "+" or "") .. n end

-- The llmsend/v1 note asking the assistant to write the chronicle and email it. meta = {datetime, id, world, to,
-- time = function(epoch) -> text}.
function M.chronicle_note(f, meta)
	local b = {}
	local function w(...) b[#b + 1] = table.concat({ ... }) end
	w("# Session chronicle: ", meta.world or "the world", "\n")
	w("A play session ended. Write its chronicle: a short, vivid saga of the night in the voice of Thufir, the world's ",
		"Mentat game master, built only from the facts below (do not invent events), then email it with ",
		"`post to ", meta.to or "<NOTIFY_TO>", " --as dune_awakening_server --subject '<title>' --body '<saga>' --yes`.")
	w("Quest ids are the game's internal names: translate them into plain words.\n")
	w("## Facts\n")
	w("- Session: ", meta.time(f.start), " to ", meta.time(f.finish), " (", f.minutes, " minutes)")
	w("- Omens whispered: ", f.omens)
	for _, k in ipairs(sorted_keys(f.worms)) do w("- Worm attacks on ", k, ": ", f.worms[k]) end
	for _, k in ipairs(sorted_keys(f.storms)) do w("- Sandstorms over ", M.region_name(k), ": ", f.storms[k]) end
	for _, p in ipairs(f.players) do
		w("\n### ", p.name, "\n")
		w("- ", signed(p.xp_gained), " XP, ", signed(p.intel_gained), " Intel, ", signed(p.skill_points_gained), " skill points")
		if #p.quests == 0 then w("- No quest steps completed") end
		for _, q in ipairs(p.quests) do w("- Completed: ", q) end
	end
	if #f.commands > 0 then
		w("\n### GM bridge commands\n")
		for _, c in ipairs(f.commands) do w("- ", c.time, " ", c.name, ": ", c.command, c.allowed and "" or " (refused)") end
	end
	local doc = cjson.encode({ schema = "llmsend/v1", subject = "Session chronicle for " .. (meta.world or "the world"),
		description = "A play session ended; write its chronicle from the facts and email it.", sender = "dune-world-watch",
		recipient = "dune_awakening_server", datetime = meta.datetime, message_type = "request", response_expected = true,
		priority = "normal", tags = { "game", "chronicle", "session", "thufir" } })
	return { name = meta.datetime:sub(1, 10) .. "-from-world-watch-chronicle-" .. meta.id .. ".frontmatter.md",
		text = "---json\n" .. doc .. "\n---\n\n" .. table.concat(b, "\n") .. "\n" }
end

return M
