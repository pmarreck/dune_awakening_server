-- Unit tests for libexec/lib/map_scaler.lua (run by tests/unit/map-scaler).
package.path = "libexec/lib/?.lua;" .. package.path
local ms = require("map_scaler")
local failures = 0
local function fail(msg) io.stderr:write("FAIL ", msg, "\n"); failures = failures + 1 end
local function eq(name, got, want)
	if got ~= want then fail(string.format("%s: got %s, want %s", name, tostring(got), tostring(want))) end
end
local function read(p) local f = assert(io.open(p)); local s = f:read("*a"); f:close(); return s end
local function env(t) return function(k) return t[k] end end
local function join(list) return table.concat(list, " ") end

-- The map table ----------------------------------------------------------------------------------------------------
local TABLE = read("data/maps.tsv")
local maps = assert(ms.parse_maps(TABLE))
eq("table first map", maps[1].name, "Survival_1")
eq("table has Arrakeen", maps.by_name.SH_Arrakeen and maps.by_name.SH_Arrakeen.slot, 3)
eq("Arrakeen game port", ms.ports(maps.by_name.SH_Arrakeen).game, 7779)
eq("Arrakeen IGW port", ms.ports(maps.by_name.SH_Arrakeen).igw, 7890)
eq("Survival_1 game port", ms.ports(maps.by_name.Survival_1).game, 7777)
eq("Survival_1 run dir", ms.run_dir("Survival_1"), "server")
eq("other run dir", ms.run_dir("SH_Arrakeen"), "server-SH_Arrakeen")
eq("comments and blanks skipped", #assert(ms.parse_maps("# c\n\nA\t2\t4G\t/Game/A.A\n")), 1)
eq("malformed row rejected", (ms.parse_maps("A\tx\t4G\t/Game/A.A\n")), nil)
eq("duplicate slot rejected", (ms.parse_maps("A\t2\t4G\t/a\nB\t2\t4G\t/b\n")), nil)

-- Configuration: which maps the world serves, which stay up, the idle window -----------------------------------------
do
	local c = assert(ms.parse_config(env({}), maps))
	eq("default: scaler on", c.enabled, true)
	eq("default: every map but Survival_1 on demand", #c.on_demand, #maps - 1)
	eq("default: none always on", #c.always_on, 0)
	eq("default: idle window", c.idle_after, 900)
	eq("default: poll", c.poll, 5)
	eq("default: Survival_1 never managed", c.managed.Survival_1, nil)
	c = assert(ms.parse_config(env({ DUNE_MAPS = "SH_Arrakeen, SH_HarkoVillage", DUNE_MAPS_ALWAYS_ON = "Overmap",
		DUNE_MAP_IDLE_AFTER = "120", DUNE_MAP_POLL = "2" }), maps))
	eq("list: on demand", join(c.on_demand), "SH_Arrakeen SH_HarkoVillage")
	eq("list: always on", join(c.always_on), "Overmap")
	eq("list: served = both, table order", join(c.maps), "Overmap SH_Arrakeen SH_HarkoVillage")
	eq("list: always-on map not managed", c.managed.Overmap, nil)
	eq("list: on-demand map managed", c.managed.SH_Arrakeen, true)
	eq("idle set", c.idle_after, 120); eq("poll set", c.poll, 2)
	-- An always-on map that is also listed in MAPS is always on, not on demand.
	c = assert(ms.parse_config(env({ DUNE_MAPS = "SH_Arrakeen Overmap", DUNE_MAPS_ALWAYS_ON = "SH_Arrakeen" }), maps))
	eq("overlap: on demand", join(c.on_demand), "Overmap"); eq("overlap: always on", join(c.always_on), "SH_Arrakeen")
	-- MAPS as a classifier over the values an operator might write: maps served on demand.
	local cases = {
		{ "", #maps - 1 }, { "all", #maps - 1 }, { "ALL", #maps - 1 }, { "none", 0 }, { "Survival_1", 0 },
		{ "SH_Arrakeen", 1 }, { "SH_Arrakeen SH_Arrakeen", 1 }, { " SH_Arrakeen,,Overmap ", 2 },
	}
	for _, k in ipairs(cases) do
		local cc = ms.parse_config(env({ DUNE_MAPS = k[1] }), maps)
		eq("MAPS=" .. k[1], cc and #cc.on_demand, k[2])
	end
	eq("none + always on", #assert(ms.parse_config(env({ DUNE_MAPS = "none", DUNE_MAPS_ALWAYS_ON = "SH_Arrakeen" }), maps)).always_on, 1)
	for v, want in pairs({ ["0"] = false, off = false, no = false, ["1"] = true, on = true, yes = true, [""] = true }) do
		local cc = ms.parse_config(env({ DUNE_MAP_SCALER = v }), maps)
		eq("switch " .. v, cc and cc.enabled, want)
	end
	-- Bad values are refused with a message naming the setting.
	local bad = { { DUNE_MAPS = "NoSuchMap" }, { DUNE_MAPS = "SH_Arrakeen;rm" }, { DUNE_MAPS_ALWAYS_ON = "NoSuchMap" },
		{ DUNE_MAPS_ALWAYS_ON = "all" }, { DUNE_MAP_IDLE_AFTER = "59" }, { DUNE_MAP_IDLE_AFTER = "ten" }, { DUNE_MAP_POLL = "0" },
		{ DUNE_MAP_SCALER = "maybe" } }
	for _, b in ipairs(bad) do
		local k = next(b)
		local cc, err = ms.parse_config(env(b), maps)
		if cc then fail("accepted " .. k .. "=" .. b[k]) end
		if not cc and not (err or ""):find(k:gsub("^DUNE_", ""), 1, true) then fail("error for " .. k .. " does not name it: " .. tostring(err)) end
	end
end

-- Travel demand from Director's log: a classifier over a set of lines --------------------------------------------------
do
	local lines = {
		{ "[00:11:03 16 INF Main] Received travel request for 1 player(s) to SH_Arrakeen (instancingMode=ClassicalInstancing)", "SH_Arrakeen:1" },
		{ "[22:03:32 16 INF Main] Received travel request for 2 player(s) to DeepDesert_1 (instancingMode=Dimension)", "DeepDesert_1:2" },
		{ "[22:06:34 22 INF Main] [1 occurrences]: Processing travel queue for SH_HarkoVillage (Abc, id=x, dimension=0, partition=4, num=1)", "SH_HarkoVillage:1" },
		{ "[22:06:34 22 INF Main] [60 occurrences]: Processing travel queue for Survival_1 (Abbir, id=x, dimension=0, partition=1, num=0)", nil },
		{ "[22:06:34 22 INF Main] Processing travel queue for ClassicalInstancing group SH_Arrakeen (servers: [], num: 3)", "SH_Arrakeen:3" },
		{ "[22:06:34 22 INF Main] Processing travel queue for ClassicalInstancing group SH_Arrakeen (servers: [a, b], num: 0)", nil },
		{ "[22:03:32 16 INF Main] Received travel request for 0 player(s) to Overmap (instancingMode=SingleServer)", nil },
		{ "[22:03:43 18 ERR Main] Remove grant from in transit found no grant matching TravelCompletion { MapName = SH_Arrakeen }", nil },
		{ "[00:09:28 12 DBG Main] Battlegroup, consuming 1 partitions from database.", nil },
		{ "Received travel request for 1 player(s) to ../../etc (instancingMode=Dimension)", nil },
		{ "", nil },
	}
	local all = {}
	for _, l in ipairs(lines) do
		local d = ms.parse_demand(l[1] .. "\n")
		local got = d[1] and (d[1].map .. ":" .. d[1].count) or nil
		eq("demand in: " .. l[1], got, l[2])
		eq("one event at most: " .. l[1], #d <= 1, true)
		all[#all + 1] = l[1]
	end
	eq("demand over the whole set", #ms.parse_demand(table.concat(all, "\n")), 4)
	-- Incremental reading: only complete lines are parsed; the rest waits for the next read.
	local done, rest = ms.complete_lines("line one\nline tw")
	eq("complete part", done, "line one\n"); eq("rest", rest, "line tw")
	done, rest = ms.complete_lines("no newline yet")
	eq("nothing complete", done, ""); eq("all rest", rest, "no newline yet")
end

-- Decisions over time ---------------------------------------------------------------------------------------------------
local CFG = assert(ms.parse_config(env({ DUNE_MAPS = "SH_Arrakeen SH_HarkoVillage", DUNE_MAPS_ALWAYS_ON = "Overmap",
	DUNE_MAP_IDLE_AFTER = "900" }), maps))

-- Drive the scaler from t0 to t1 in steps of cfg.poll. world(t) returns {demand = {map = n}, players = {map = n} or
-- false (unknown)}; starts and stops change `running` (a start fails when fail_start(map, t)). Returns the actions as
-- "t:start map" / "t:stop map" and the events.
local function drive(o)
	local cfg = o.cfg or CFG
	local st = ms.initial_state()
	local running = o.running or {}
	local log, events = {}, {}
	local t = o.t0 or 0
	while t <= o.t1 do
		local w = o.world and o.world(t) or {}
		local players = w.players
		if players == nil then players = {} end
		if players == false then players = nil end
		local actions, ev
		st, actions, ev = ms.step(st, { demand = w.demand or {}, players = players, running = running }, t, cfg)
		for _, e in ipairs(ev) do events[#events + 1] = t .. ":" .. e end
		for _, a in ipairs(actions) do
			log[#log + 1] = t .. ":" .. a.action .. " " .. a.map
			local ok = not (o.fail_start and a.action == "start" and o.fail_start(a.map, t))
			if a.action == "start" and ok then running[a.map] = true end
			if a.action == "stop" then running[a.map] = nil end
			st = ms.done(st, a, ok, t)
		end
		t = t + cfg.poll
	end
	return table.concat(log, ","), events
end

do
	-- Nothing happens without demand.
	eq("no demand", drive({ t1 = 5000 }), "")
	-- A demand starts the map once; nobody arrives; it stops idle_after after the start.
	eq("demand, nobody comes", drive({ t1 = 2000, world = function(t) return { demand = t == 10 and { SH_Arrakeen = 1 } or nil } end }),
		"10:start SH_Arrakeen,910:stop SH_Arrakeen")
	-- Repeated demand while it runs does not start it again, and pushes the idle window out.
	eq("repeated demand", drive({ t1 = 2000, world = function(t) return { demand = (t == 10 or t == 500) and { SH_Arrakeen = 1 } or nil } end }),
		"10:start SH_Arrakeen,1400:stop SH_Arrakeen")
	-- Players keep it up; it stops idle_after after the last one leaves.
	eq("players keep it", drive({ t1 = 5000, world = function(t)
		return { demand = t == 10 and { SH_Arrakeen = 1 } or nil, players = { SH_Arrakeen = (t >= 100 and t < 3000) and 1 or 0 } }
	end }), "10:start SH_Arrakeen,3895:stop SH_Arrakeen")
	-- Unknown player counts (database unreachable) never stop a map.
	eq("unknown players", drive({ t1 = 5000, world = function(t)
		local w = { demand = t == 10 and { SH_Arrakeen = 1 } or nil }; if t > 500 then w.players = false end; return w
	end }), "10:start SH_Arrakeen")
	-- Survival_1, always-on maps and maps the world does not serve are never started or stopped.
	eq("not managed", drive({ t1 = 2000, running = { Overmap = true, Survival_1 = true }, world = function(t)
		return { demand = t == 10 and { Survival_1 = 1, Overmap = 1, DeepDesert_1 = 1 } or nil }
	end }), "")
	-- A map already running when the scaler starts (adopted) gets the full idle window from then.
	eq("adopted", drive({ t1 = 2000, running = { SH_HarkoVillage = true } }), "900:stop SH_HarkoVillage")
	-- A failed start is retried while the demand is fresh, at most once a minute, and given up after the window.
	eq("failed start retried", drive({ t1 = 3000, fail_start = function() return true end,
		world = function(t) return { demand = t == 10 and { SH_Arrakeen = 1 } or nil } end }),
		"10:start SH_Arrakeen,70:start SH_Arrakeen,130:start SH_Arrakeen,190:start SH_Arrakeen,250:start SH_Arrakeen,310:start SH_Arrakeen," ..
		"370:start SH_Arrakeen,430:start SH_Arrakeen,490:start SH_Arrakeen,550:start SH_Arrakeen,610:start SH_Arrakeen,670:start SH_Arrakeen," ..
		"730:start SH_Arrakeen,790:start SH_Arrakeen,850:start SH_Arrakeen")
	eq("second start succeeds", drive({ t1 = 2000, fail_start = function(_, t) return t < 60 end,
		world = function(t) return { demand = t == 10 and { SH_Arrakeen = 1 } or nil } end }), "10:start SH_Arrakeen,70:start SH_Arrakeen,970:stop SH_Arrakeen")
	-- A map that dies on its own is not restarted without new demand.
	local running = {}
	eq("crash", drive({ t1 = 2000, running = running, world = function(t)
		if t == 300 then running.SH_Arrakeen = nil end
		return { demand = t == 10 and { SH_Arrakeen = 1 } or nil }
	end }), "10:start SH_Arrakeen")
	-- Two maps at once, each on its own clock.
	eq("two maps", drive({ t1 = 3000, world = function(t)
		return { demand = (t == 10 and { SH_Arrakeen = 1 }) or (t == 400 and { SH_HarkoVillage = 2 }) or nil }
	end }), "10:start SH_Arrakeen,400:start SH_HarkoVillage,910:stop SH_Arrakeen,1300:stop SH_HarkoVillage")
	-- Scaler off: demand is logged, nothing is started; a running map is left alone.
	local off = assert(ms.parse_config(env({ DUNE_MAPS = "SH_Arrakeen", DUNE_MAP_SCALER = "0" }), maps))
	local log, events = drive({ cfg = off, t1 = 2000, running = { SH_Arrakeen = true }, world = function(t) return { demand = t == 10 and { SH_Arrakeen = 1 } or nil } end })
	eq("off: no actions", log, "")
	eq("off: demand logged", events[1], "10:demand for SH_Arrakeen (1 player); scaler off, not starting it")
	-- Events name what happened, in plain words.
	local _, ev = drive({ t1 = 1000, world = function(t)
		return { demand = t == 10 and { SH_Arrakeen = 2 } or nil, players = { SH_Arrakeen = (t >= 100 and t < 200) and 1 or 0 } }
	end })
	eq("events", table.concat(ev, "|"), "10:demand for SH_Arrakeen (2 players)|10:starting SH_Arrakeen|100:SH_Arrakeen: 1 player on it|" ..
		"200:SH_Arrakeen: nobody on it")
end

os.exit(failures == 0 and 0 or 1)
