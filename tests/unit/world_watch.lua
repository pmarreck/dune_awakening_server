-- Unit tests for libexec/lib/world_watch.lua (run by tests/unit/world-watch): log parsing, omen choice and cooldowns,
-- session boundaries, and the chronicle facts and note.
package.path = "libexec/lib/?.lua;" .. package.path
local ww = require("world_watch")
local cjson = require("cjson")
local failures = 0
local function fail(msg) io.stderr:write("FAIL ", msg, "\n"); failures = failures + 1 end
local function eq(name, got, want)
	if got ~= want then fail(string.format("%s: got %s, want %s", name, tostring(got), tostring(want))) end
end
local function env(t) return function(k) return t[k] end end
local function first(rng_n) return function(n) return rng_n or 1 end end

-- Configuration ------------------------------------------------------------------------------------------------
do
	local c = assert(ww.parse_config(env({})))
	eq("default omens", c.omens, true); eq("default chronicle", c.chronicle, true); eq("default from", c.from, "Thufir")
	eq("default chase gap", c.chase_gap, 180); eq("default worm cooldown", c.worm_cooldown, 60); eq("default storm cooldown", c.storm_cooldown, 1800)
	eq("default session gap", c.session_gap, 900); eq("default session min", c.session_min, 600)
	eq("default poll", c.poll, 2); eq("default roster", c.roster_every, 60)
	c = assert(ww.parse_config(env({ DUNE_OMENS = "0", DUNE_CHRONICLE = "off", DUNE_OMEN_FROM = "Stilgar", DUNE_OMEN_COOLDOWN = "30",
		DUNE_STORM_OMEN_COOLDOWN = "0", DUNE_CHRONICLE_GAP = "60", DUNE_CHRONICLE_MIN = "0", DUNE_WATCH_POLL = "1", DUNE_WATCH_ROSTER = "5" })))
	eq("omens off", c.omens, false); eq("chronicle off", c.chronicle, false); eq("from set", c.from, "Stilgar")
	eq("worm cooldown set", c.worm_cooldown, 30); eq("storm cooldown 0", c.storm_cooldown, 0)
	eq("gap set", c.session_gap, 60); eq("min 0", c.session_min, 0); eq("poll set", c.poll, 1); eq("roster set", c.roster_every, 5)
	for _, b in ipairs({ { DUNE_OMENS = "maybe" }, { DUNE_OMEN_COOLDOWN = "-1" }, { DUNE_OMEN_COOLDOWN = "1.5" }, { DUNE_WATCH_POLL = "0" },
		{ DUNE_WATCH_ROSTER = "0" }, { DUNE_CHRONICLE_GAP = "0" }, { DUNE_CHRONICLE_MIN = "x" }, { DUNE_OMEN_FROM = "" .. string.rep("x", 33) } }) do
		local k = next(b)
		local cc, err = ww.parse_config(env(b))
		if cc then fail("accepted " .. k .. "=" .. b[k]) end
		if not cc and not (err or ""):find(k:gsub("^DUNE_", ""), 1, true) then fail("error for " .. k .. " does not name it: " .. tostring(err)) end
	end
end

-- Log lines ----------------------------------------------------------------------------------------------------
local function worm_line(id, target, enraged, tail)
	return string.format("[2026.10.20-18.04.13:713][803][3733012][1]LogDuneSandworm: Log: [BP_Crea_SandwormArrakis_C_2147343430, ID: %d, "
		.. "V(X=102839.73, Y=-34109.81, Z=-8317.79), RootBoneZ: -8318, ESandwormSteeringMode::Attack, Sandworm isn't playing any animation, "
		.. "ESandwormAnimationState::None, ESandwormChaseAttackStateType::None, InSafeZone:0, Enraged:%d, EThreatBlobType::%s] %s",
		id, enraged and 1 or 0, target, tail or "hide 10.000000 seconds before teleporting to attack")
end
do
	local e = ww.parse_line(worm_line(7, "Character", true))
	eq("worm kind", e and e.kind, "worm"); eq("worm id", e and e.worm, 7); eq("worm target", e and e.target, "Character")
	eq("worm enraged", e and e.enraged, true); eq("worm lead", e and e.lead, 10)
	eq("calm worm", ww.parse_line(worm_line(1, "ValuableDesertWreck", false)).enraged, false)
	-- Only the line announcing the attack counts: the same attack logs "is hidden" and animation lines too.
	eq("is hidden ignored", ww.parse_line(worm_line(7, "Character", false, "is hidden")), nil)
	eq("animation ignored", ww.parse_line(worm_line(7, "Character", false, "Finished playing animation: AnimMontage /Game/X")), nil)
	eq("attack stage", e and e.stage, "attack")
	-- A worm hunting players breaches beside them in Roam mode before (or instead of) attacking, and logs the
	-- target it picks before either (shapes from a live crossing, 2026-10-27): both count, in any steering mode.
	local roam = function(l) return (l:gsub("SteeringMode::Attack", "SteeringMode::Roam")) end
	local b = ww.parse_line(roam(worm_line(100, "Group", false, "hide 5.000000 seconds before teleporting to breach")))
	eq("breach kind", b and b.kind, "worm"); eq("breach target", b and b.target, "Group"); eq("breach lead", b and b.lead, 5)
	eq("breach stage", b and b.stage, "breach")
	local picked = roam(worm_line(100, "Vehicle", false, "x")):gsub("EThreatBlobType::Vehicle%] x",
		"NoTargetBlob] SetCurrentThreatBlob; Type: EThreatBlobType::Vehicle, Location V(X=75437.01, Y=209783.68, Z=712.15)")
	local t = ww.parse_line(picked)
	eq("target pick kind", t and t.kind, "worm"); eq("target pick worm", t and t.worm, 100)
	eq("target pick target", t and t.target, "Vehicle"); eq("target pick stage", t and t.stage, "target"); eq("target pick lead", t and t.lead, nil)
	eq("roam attack counted", ww.parse_line(roam(worm_line(7, "Character", false))) ~= nil, true)
	-- The other approach lines repeat what those say and are ignored.
	for _, tail in ipairs({ "wants to breach", "is shown", "no longer wants to breach",
		"teleport and execute breach. TeleportLocation: V(X=1, Y=2, Z=3)", "teleport and execute vertical attack. TeleportLocation: V(X=1, Y=2, Z=3)",
		"Sandworm starts playing Breach animation at time: 2026.10.26-14.03.22." }) do
		eq("ignored: " .. tail, ww.parse_line(roam(worm_line(100, "Group", false, tail))), nil)
	end
	local s = ww.parse_line("[2026.10.20-18.10.01:100][771][3733012][1]LogSandStormManager: Log: Requested a Sandstorm auto-spawn on [HaggaBasin] Server 1 Dimension 0")
	eq("storm kind", s and s.kind, "storm"); eq("storm region", s and s.region, "HaggaBasin")
	eq("storm begin ignored", ww.parse_line("[x][1]LogSandStorm: Log: Sandstorm BeginPlay on [HaggaBasin] Server 1 Dimension 0"), nil)
	eq("blank", ww.parse_line(""), nil)
	eq("other", ww.parse_line("LogNet: Login request: ?Name=Alice"), nil)
end

-- Which attack targets earn an omen, over every threat type the 1.5 server binary defines.
do
	local want = { Character = "character", Group = "character", Vehicle = "vehicle", Thumper = "thumper", UniqueThumper = "thumper",
		Area = false, Default = false, DesertWreck = false, ValuableDesertWreck = false, Npc = false, Spice = false }
	for t, w in pairs(want) do eq("omen target " .. t, ww.omen_target(t) or false, w) end
	eq("unknown target", ww.omen_target("SomethingNew"), nil)
end

do
	eq("region spaced", ww.region_name("HaggaBasin"), "Hagga Basin")
	eq("region deep desert", ww.region_name("DeepDesert"), "Deep Desert")
	eq("region one word", ww.region_name("Arrakeen"), "Arrakeen")
end

-- Omen table ---------------------------------------------------------------------------------------------------
local OMENS_TSV = "# kind\ttext\nworm-character\tThe sand trembles.\nworm-character\tWormsign!\nworm-vehicle\tYour engine sings.\n"
	.. "worm-thumper\tThe thumper calls.\nstorm\tA storm gathers over {region}.\n\n"
do
	local o = assert(ww.parse_omens(OMENS_TSV))
	eq("two character omens", #o["worm-character"], 2); eq("one storm omen", #o.storm, 1)
	local bad, err = ww.parse_omens("worm-character\tok\nworm-dragon\tnope\n")
	eq("unknown kind rejected", bad, nil)
	if not (err or ""):find("line 2", 1, true) then fail("unknown kind error has no line number: " .. tostring(err)) end
	eq("missing text rejected", (ww.parse_omens("storm\t\n")), nil)
	eq("missing tab rejected", (ww.parse_omens("storm only\n")), nil)
	-- The repository's own table must parse and cover every kind.
	local f = assert(io.open("data/omens.tsv")); local real = assert(ww.parse_omens(f:read("*a"))); f:close()
	for _, k in ipairs({ "worm-character", "worm-vehicle", "worm-thumper", "storm" }) do
		if not real[k] or #real[k] == 0 then fail("data/omens.tsv has no " .. k .. " lines") end
	end
	for _, line in ipairs(real.storm or {}) do
		if not line:find("{region}", 1, true) then fail("storm omen without {region}: " .. line) end
	end
end

-- Events: omens and the session tally ---------------------------------------------------------------------------
local cfg = assert(ww.parse_config(env({})))
local omens = assert(ww.parse_omens(OMENS_TSV))
local ONLINE = { "Alice", "Bob" }
local function worm(id, target) return { kind = "worm", worm = id, target = target, enraged = false, lead = 10 } end
do
	-- No session (nobody connected): nothing is sent or tallied.
	local st = ww.new_state()
	local w
	st, w = ww.on_event(st, worm(1, "Character"), 1000, cfg, omens, first(), ONLINE)
	eq("no session no whisper", #w, 0)

	st = ww.on_presence(st, 1, 1000, cfg)
	st, w = ww.on_event(st, worm(1, "Character"), 1001, cfg, omens, first(2), ONLINE)
	eq("whisper per online player", #w, 2)
	eq("whisper to", w[1].to, "Alice"); eq("whisper to 2", w[2].to, "Bob")
	eq("whisper text from rng", w[1].text, "Wormsign!"); eq("same text for both", w[2].text, "Wormsign!")
	eq("tally character", st.session.worms.Character, 1); eq("omen counted", st.session.omens, 1)

	-- A chase is every player-target line with gaps of at most WORM_CHASE_GAP (180 s), whatever the worm id or the
	-- player target: ids change mid-chase (75, 20, 255, 1 in one crossing, 2026-10-27). Its later lines stay quiet
	-- and are not tallied again.
	st, w = ww.on_event(st, worm(1, "Character"), 1020, cfg, omens, first(), ONLINE)
	eq("chase line quiet", #w, 0); eq("chase line not tallied", st.session.worms.Character, 1)
	st, w = ww.on_event(st, worm(2, "Vehicle"), 1030, cfg, omens, first(), ONLINE)
	eq("other worm id, same chase", #w, 0); eq("switch to vehicle not tallied", st.session.worms.Vehicle, nil)
	st, w = ww.on_event(st, worm(3, "Group"), 1200, cfg, omens, first(), ONLINE)
	eq("gap under the chase gap", #w, 0); eq("group not tallied", st.session.worms.Group, nil)
	-- Quiet for longer than the gap: the next line starts a new chase and warns, with that target's line.
	st, w = ww.on_event(st, worm(3, "Vehicle"), 1400, cfg, omens, first(), ONLINE)
	eq("new chase after the gap", #w, 2); eq("vehicle text", w[1].text, "Your engine sings."); eq("new chase tallied", st.session.worms.Vehicle, 1)
	-- Wrecks: chases of their own, tallied, never an omen, and they do not keep a player chase alive.
	st, w = ww.on_event(st, worm(4, "ValuableDesertWreck"), 1401, cfg, omens, first(), ONLINE)
	eq("wreck quiet", #w, 0); eq("wreck tallied", st.session.worms.ValuableDesertWreck, 1)
	st, w = ww.on_event(st, worm(4, "ValuableDesertWreck"), 1450, cfg, omens, first(), ONLINE)
	eq("wreck chase tallied once", st.session.worms.ValuableDesertWreck, 1)
	st, w = ww.on_event(st, worm(5, "Thumper"), 1590, cfg, omens, first(), ONLINE)
	eq("wreck lines did not extend the player chase", #w, 2); eq("thumper text", w[1].text, "The thumper calls.")
	-- A chase that starts with nobody online warns at its next line once someone is; tallied once.
	st, w = ww.on_event(st, worm(6, "Character"), 2000, cfg, omens, first(), {})
	eq("no recipients", #w, 0); eq("tallied without recipients", st.session.worms.Character, 2)
	eq("unheard not counted", st.session.omens, 3)
	st, w = ww.on_event(st, worm(6, "Character"), 2001, cfg, omens, first(), ONLINE)
	eq("unwarned chase warns at its next line", #w, 2); eq("not tallied twice", st.session.worms.Character, 2)
	st, w = ww.on_event(st, worm(6, "Character"), 2002, cfg, omens, first(), ONLINE)
	eq("warned once per chase", #w, 0)
	-- A chase that starts inside the omen cooldown warns at its first line after the cooldown.
	local quick = assert(ww.parse_config(env({ DUNE_WORM_CHASE_GAP = "5" })))
	eq("chase gap setting", quick.chase_gap, 5)
	local st3 = ww.on_presence(ww.new_state(), 1, 100, quick)
	local w3, heard = nil, {}
	st3, w3 = ww.on_event(st3, worm(1, "Character"), 100, quick, omens, first(), ONLINE)
	for t = 120, 170, 4 do
		st3, w3 = ww.on_event(st3, worm(1, "Character"), t, quick, omens, first(), ONLINE)
		if #w3 > 0 then heard[#heard + 1] = t end
	end
	eq("cooldown holds the second chase until 160", table.concat(heard, ","), "160")

	-- A worm that turns from a wreck to a player within the cooldown is a new hunt: the player hears it.
	local st2 = ww.on_presence(ww.new_state(), 1, 5000, cfg)
	local w2
	st2, w2 = ww.on_event(st2, worm(9, "ValuableDesertWreck"), 5001, cfg, omens, first(), ONLINE)
	eq("wreck hunt quiet", #w2, 0)
	st2, w2 = ww.on_event(st2, worm(9, "Vehicle"), 5010, cfg, omens, first(), ONLINE)
	eq("same worm, now after a vehicle: omen", #w2, 2)
	-- Switching between player targets (vehicle, group) within the cooldown is the same hunt: one tally, no repeat.
	st2, w2 = ww.on_event(st2, worm(9, "Group"), 5015, cfg, omens, first(), ONLINE)
	eq("vehicle to group: same hunt", #w2, 0)
	eq("one wreck hunt", st2.session.worms.ValuableDesertWreck, 1); eq("one vehicle hunt", st2.session.worms.Vehicle, 1)
	eq("group switch not tallied", st2.session.worms.Group, nil)

	-- Storms: region filled in, one omen per storm cooldown, every storm tallied.
	local storm = { kind = "storm", region = "HaggaBasin" }
	st, w = ww.on_event(st, storm, 1500, cfg, omens, first(), ONLINE)
	eq("storm whisper", #w, 2); eq("storm text", w[1].text, "A storm gathers over Hagga Basin.")
	st, w = ww.on_event(st, storm, 1600, cfg, omens, first(), ONLINE)
	eq("storm cooldown", #w, 0); eq("storms tallied", st.session.storms.HaggaBasin, 2)

	-- Omens switched off: still tallied for the chronicle.
	local off = assert(ww.parse_config(env({ DUNE_OMENS = "0" })))
	st, w = ww.on_event(st, worm(9, "Character"), 5000, off, omens, first(), ONLINE)
	eq("omens off quiet", #w, 0); eq("omens off tallied", st.session.worms.Character, 3)

	-- The state survives a round trip through its file format.
	local back = ww.decode(ww.encode(st))
	eq("decode keeps tally", back.session.worms.Character, 3); eq("decode keeps start", back.session.start, 1000)
	eq("decode of nothing", ww.decode(nil).session, nil); eq("decode of junk", ww.decode("{not json").session, nil)
end

-- Sessions -----------------------------------------------------------------------------------------------------
do
	local st, done = ww.new_state(), nil
	st, done = ww.on_presence(st, 0, 100, cfg); eq("idle no session", st.session, nil); eq("idle nothing done", done, nil)
	st = ww.on_presence(st, 2, 1000, cfg); eq("session start", st.session.start, 1000)
	st = ww.on_presence(st, 1, 2000, cfg); eq("last seen", st.session.last_seen, 2000)
	-- A short gap (a reconnect, a crash) keeps the same session.
	st, done = ww.on_presence(st, 0, 2000 + cfg.session_gap - 1, cfg); eq("gap kept", done, nil)
	st = ww.on_presence(st, 1, 3000, cfg); eq("same session", st.session.start, 1000)
	st = ww.on_roster(st, { { id = 2, name = "Alice", online = true, xp_total = 100, intel_points = 5, skill_points_total = 3 },
		{ id = 3, name = "Bob", online = false, xp_total = 50 } }, { [2] = { a = true } }, 3000)
	st, done = ww.on_presence(st, 0, 3000 + cfg.session_gap, cfg)
	eq("session closed", st.session, nil)
	eq("finished start", done and done.start, 1000); eq("finished end is last seen", done and done.finish, 3000)

	-- Too short, or nobody ever showed up in the roster: no chronicle.
	st = ww.on_presence(ww.new_state(), 1, 0, cfg)
	st = ww.on_roster(st, { { id = 2, name = "Alice", online = true, xp_total = 1 } }, {}, 0)
	st, done = ww.on_presence(st, 0, cfg.session_min - 1 + cfg.session_gap, cfg)
	eq("short session dropped", done, nil); eq("short session closed", st.session, nil)
	st = ww.on_presence(ww.new_state(), 1, 0, cfg)
	st, done = ww.on_presence(st, 0, 5000 + cfg.session_gap, cfg)
	st = ww.on_presence(st, 1, 5000, cfg)
	st, done = ww.on_presence(st, 0, 9000 + cfg.session_gap, cfg)
	eq("no players dropped", done, nil)
end

-- Roster: the first sighting of each character is the baseline; later ones only refresh the latest values.
do
	local st = ww.on_presence(ww.new_state(), 1, 0, cfg)
	st = ww.on_roster(st, { { id = 3, name = "Bob", online = false, xp_total = 10 } }, {}, 5)
	eq("offline character has no baseline", st.session.players["3"], nil)
	st = ww.on_roster(st, { { id = 2, name = "Alice", online = true, xp_total = 100, intel_points = 5, skill_points_total = 3 } },
		{ [2] = { q1 = true }, [3] = { b1 = true } }, 10)
	st = ww.on_roster(st, { { id = 2, name = "Alice", online = true, xp_total = 900, intel_points = 7, skill_points_total = 4 },
		{ id = 3, name = "Bob", online = true, xp_total = 40, intel_points = 0, skill_points_total = 0 } }, { [2] = { q1 = true, q2 = true }, [3] = { b1 = true } }, 20)
	st = ww.on_roster(st, { { id = 2, name = "Alice", online = false, xp_total = 950, intel_points = 7, skill_points_total = 4 } }, {}, 30)
	local a, b = st.session.players["2"], st.session.players["3"]
	eq("alice baseline xp", a.first.xp_total, 100); eq("alice latest xp", a.last.xp_total, 950)
	eq("alice baseline quests", a.quests.q1, true); eq("alice baseline lacks q2", a.quests.q2, nil)
	eq("bob baseline", b.first.xp_total, 40)

	-- The chronicle: gains, quests completed since the baseline (from the final quest read), worms, storms, commands.
	st.session.worms = { Character = 2, ValuableDesertWreck = 3 }; st.session.storms = { HaggaBasin = 1 }; st.session.omens = 3
	local bridge = table.concat({
		"1970-01-01T00:00:05Z 0123456789ABCDEF Alice allowed: &help",
		"1970-01-01T00:00:00Z 0123456789ABCDEF Alice allowed: &early",
		"1970-01-01T00:00:15Z FEDCBA9876543210 Paul of Caladan denied: &water",
		"1970-01-01T00:00:16Z started (pid 1)",
		"1970-01-01T00:00:40Z 0123456789ABCDEF Alice allowed: &late",
	}, "\n")
	local cmds = ww.parse_bridge_log(bridge, 1, 30)
	eq("bridge in window", #cmds, 2); eq("bridge name with spaces", cmds[2].name, "Paul of Caladan")
	eq("bridge allowed", cmds[1].allowed, true); eq("bridge denied", cmds[2].allowed, false); eq("bridge command", cmds[2].command, "&water")

	local session = st.session
	session.finish = 30
	local facts = ww.chronicle(session, { [2] = { q1 = true, q2 = true, q3 = true }, [3] = { b1 = true } }, cmds)
	eq("facts minutes", facts.minutes, 1); eq("facts players", #facts.players, 2)
	local fa = facts.players[1]
	eq("players sorted by name", fa.name, "Alice")
	eq("xp gained", fa.xp_gained, 850); eq("intel gained", fa.intel_gained, 2); eq("skill points gained", fa.skill_points_gained, 1)
	eq("quests completed", #fa.quests, 2); eq("quests sorted", fa.quests[1], "q2")
	eq("bob no quests", #facts.players[2].quests, 0)
	eq("facts worms", facts.worms.Character, 2); eq("facts storms", facts.storms.HaggaBasin, 1); eq("facts commands", #facts.commands, 2)

	local note = ww.chronicle_note(facts, { datetime = "2026-10-24T23:30:00-04:00", id = "ab12cd34", world = "My World", to = "op@example.org",
		time = function(t) return "T" .. t end })
	eq("note name", note.name, "2026-10-24-from-world-watch-chronicle-ab12cd34.frontmatter.md")
	local meta = cjson.decode(note.text:match("^%-%-%-json\n(.-)\n%-%-%-\n"))
	eq("note schema", meta.schema, "llmsend/v1"); eq("note type", meta.message_type, "request"); eq("note response", meta.response_expected, true)
	for _, want in ipairs({ "My World", "op@example.org", "Alice", "+850 XP", "q2", "q3", "Paul of Caladan", "&water", "Hagga Basin",
		"Character", "T0", "T30" }) do
		if not note.text:find(want, 1, true) then fail("chronicle note lacks " .. want) end
	end
	if note.text:find("q1", 1, true) then fail("chronicle note lists a quest completed before the session") end
end

if failures > 0 then io.stderr:write(failures, " failure(s)\n"); os.exit(1) end
