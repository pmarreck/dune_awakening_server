-- map_scaler: pure logic of the on-demand map scaler (libexec/dune-map-scaler does the I/O). Funcom's Kubernetes
-- operator starts a map server when Director wants one; here Director's own log is the signal: "Received travel
-- request for N player(s) to MAP" (logged at once) and "Processing travel queue for ... MAP (... num=N)" (summarized
-- once a minute). A demanded map is started; it is stopped once nobody has been on it (farm_state.connected_players)
-- for the idle window, counted from the start, the last demand or the last player, whichever is latest. A state
-- machine over (state, observation, now, config) with an injected clock; the caller reports each action's outcome.
local M = {}

local GAME_PORT_BASE, IGW_PORT_BASE = 7776, 7887
local HOME_MAP = "Survival_1" -- always on, started by dune-awakening itself; never managed here
local RETRY_SECONDS = 60       -- a failed start is retried at most this often while its demand is fresh

-- data/maps.tsv: map, slot, memory cap, level URL (tab-separated; # comments). Returns the list (table order) with a
-- by_name index, or nil, message.
function M.parse_maps(text)
	local list, by_name, slots = {}, {}, {}
	local n = 0
	for line in ((text or "") .. "\n"):gmatch("([^\n]*)\n") do
		n = n + 1
		if line ~= "" and not line:match("^#") then
			local name, slot, mem, url = line:match("^([%w_]+)\t(%d+)\t(%d+G)\t(%S+)$")
			if not name then return nil, "maps table line " .. n .. " is malformed" end
			slot = tonumber(slot)
			if by_name[name] or slots[slot] then return nil, "maps table line " .. n .. " repeats a map or slot" end
			local m = { name = name, slot = slot, memory = mem, url = url }
			list[#list + 1], by_name[name], slots[slot] = m, m, true
		end
	end
	list.by_name = by_name
	return list
end

function M.ports(m) return { game = GAME_PORT_BASE + m.slot, igw = IGW_PORT_BASE + m.slot } end

-- A map's run directory under DUNE_STATE_DIR (dune-server's layout).
function M.run_dir(name) return name == HOME_MAP and "server" or ("server-" .. name) end

local SWITCH = { ["0"] = false, off = false, ["false"] = false, no = false, ["1"] = true, on = true, ["true"] = true, yes = true }

-- A list setting: names separated by spaces or commas; each must be in the table. Returns a set, or nil, message.
local function name_set(value, key, maps)
	local set = {}
	for w in (value or ""):gmatch("[^%s,]+") do
		if not maps.by_name[w] then return nil, string.format("%s: unknown map %s (see data/maps.tsv)", key, w) end
		set[w] = true
	end
	return set
end

-- Settings from DUNE_* variables (bin/dune-awakening fills them from world.conf keys without the prefix):
-- MAPS (all | none | names) maps served on demand besides Survival_1; MAPS_ALWAYS_ON (names) maps started with the
-- world and never stopped here; MAP_SCALER (1/0); MAP_IDLE_AFTER (s, >= 60); MAP_POLL (s, >= 1).
-- Returns {enabled, maps, on_demand, always_on, managed, idle_after, poll} or nil, message.
function M.parse_config(get, maps)
	local c = {}
	local sw = get("DUNE_MAP_SCALER")
	if sw == nil or sw == "" then c.enabled = true
	elseif SWITCH[sw:lower()] ~= nil then c.enabled = SWITCH[sw:lower()]
	else return nil, "MAP_SCALER must be 1 or 0 (on/off), got " .. sw end
	local served
	local v = get("DUNE_MAPS")
	if v == nil or v:match("^%s*$") or v:lower():match("^%s*all%s*$") then
		served = {}
		for _, m in ipairs(maps) do served[m.name] = true end
	elseif v:lower():match("^%s*none%s*$") then served = {}
	else
		local err
		served, err = name_set(v, "MAPS", maps)
		if not served then return nil, err end
	end
	local always, err = name_set(get("DUNE_MAPS_ALWAYS_ON"), "MAPS_ALWAYS_ON", maps)
	if not always then return nil, err end
	for _, s in ipairs({ { "idle_after", "MAP_IDLE_AFTER", 900, 60 }, { "poll", "MAP_POLL", 5, 1 } }) do
		local raw = get("DUNE_" .. s[2])
		if raw == nil or raw == "" then c[s[1]] = s[3]
		else
			local n = raw:match("^%d+$") and tonumber(raw)
			if not n or n < s[4] then return nil, string.format("%s must be a whole number >= %d, got %s", s[2], s[4], raw) end
			c[s[1]] = n
		end
	end
	c.maps, c.on_demand, c.always_on, c.managed = {}, {}, {}, {}
	for _, m in ipairs(maps) do
		local name = m.name
		if name ~= HOME_MAP then
			if always[name] then
				c.always_on[#c.always_on + 1] = name; c.maps[#c.maps + 1] = name
			elseif served[name] then
				c.on_demand[#c.on_demand + 1] = name; c.maps[#c.maps + 1] = name; c.managed[name] = true
			end
		end
	end
	return c
end

-- Director log text -> list of {map, count} for requests with count > 0, in order.
function M.parse_demand(text)
	local out = {}
	for line in (text or ""):gmatch("[^\n]+") do
		local n, map = line:match("Received travel request for (%d+) player%(s%) to ([%w_]+) %(")
		if not n then map, n = line:match("Processing travel queue for ClassicalInstancing group ([%w_]+) %(servers: %[[^%]]*%], num: (%d+)%)") end
		if not n then map, n = line:match("Processing travel queue for ([%w_]+) %(.*num ?[=:] ?(%d+)%)") end
		n = tonumber(n)
		if n and n > 0 then out[#out + 1] = { map = map, count = n } end
	end
	return out
end

-- Split read text into its complete lines and the unterminated rest (kept for the next read).
function M.complete_lines(text)
	local cut = text:match(".*()\n")
	if not cut then return "", text end
	return text:sub(1, cut), text:sub(cut + 1)
end

local function plural(n, word) return n .. " " .. word .. (n == 1 and "" or "s") end

function M.initial_state() return { maps = {} } end

local function copy_state(state)
	local s = { maps = {} }
	for k, v in pairs(state.maps) do
		local r = {}
		for kk, vv in pairs(v) do r[kk] = vv end
		s.maps[k] = r
	end
	return s
end

-- One poll. obs = {demand = {map = n}, players = {map = n} or nil when unknown, running = {map = true}}. Returns the
-- new state, the actions ({action = "start"|"stop", map}) and log events.
function M.step(state, obs, now, cfg)
	local s, actions, events = copy_state(state), {}, {}
	for map, n in pairs(obs.demand or {}) do
		if cfg.managed[map] then
			local r = s.maps[map] or {}
			s.maps[map] = r
			r.wanted = now
			if cfg.enabled then
				events[#events + 1] = string.format("demand for %s (%s)", map, plural(n, "player"))
				if not obs.running[map] then r.pending = true end
			else
				events[#events + 1] = string.format("demand for %s (%s); scaler off, not starting it", map, plural(n, "player"))
			end
		end
	end
	for _, map in ipairs(cfg.on_demand) do
		local r = s.maps[map]
		if obs.running[map] then
			r = r or {}
			s.maps[map] = r
			r.pending, r.last_try = nil, nil
			r.started = r.started or now -- adopted: running before this scaler saw it start
			local n = obs.players and (obs.players[map] or 0)
			if n and n > 0 then
				if not r.occupied then events[#events + 1] = string.format("%s: %s on it", map, plural(n, "player")) end
				r.occupied, r.active = true, now
			elseif n == 0 and r.occupied then
				events[#events + 1] = string.format("%s: nobody on it", map)
				r.occupied = nil
			end
			local since = math.max(r.started, r.wanted or r.started, r.active or r.started)
			if cfg.enabled and n == 0 and now - since >= cfg.idle_after then
				actions[#actions + 1] = { action = "stop", map = map, idle = now - since }
			end
		elseif r then
			r.started, r.occupied, r.active = nil, nil, nil
			local fresh = r.wanted and now - r.wanted < cfg.idle_after
			if cfg.enabled and r.pending and fresh and (not r.last_try or now - r.last_try >= RETRY_SECONDS) then
				actions[#actions + 1] = { action = "start", map = map }
				events[#events + 1] = "starting " .. map
			elseif not fresh then
				s.maps[map] = nil
			end
		end
	end
	return s, actions, events
end

-- Outcome of an action. A start that worked begins the map's idle clock; one that failed is retried (while its demand
-- is fresh) no sooner than RETRY_SECONDS later. A stop forgets the map.
function M.done(state, action, ok, now)
	local s = copy_state(state)
	local r = s.maps[action.map] or {}
	if action.action == "start" then
		if ok then r.started, r.pending, r.last_try = now, nil, nil else r.last_try = now end
		s.maps[action.map] = r
	elseif action.action == "stop" and ok then
		s.maps[action.map] = nil
	end
	return s
end

return M
