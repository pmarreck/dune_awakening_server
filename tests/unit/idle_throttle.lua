-- Unit tests for libexec/lib/idle_throttle.lua (run by tests/unit/idle-throttle). Addresses are documentation ranges.
package.path = "libexec/lib/?.lua;" .. package.path
local it = require("idle_throttle")
local failures = 0
local function fail(msg) io.stderr:write("FAIL ", msg, "\n"); failures = failures + 1 end
local function eq(name, got, want)
	if got ~= want then fail(string.format("%s: got %s, want %s", name, tostring(got), tostring(want))) end
end

local DAY, WEEK = 86400, 604800

-- Configuration ------------------------------------------------------------------------------------------------
local function env(t) return function(k) return t[k] end end
do
	local c = assert(it.parse_config(env({})))
	eq("default enabled", c.enabled, true)
	eq("default active", c.active_fps, 20); eq("default idle", c.idle_fps, 5); eq("default deep", c.deep_fps, 1)
	eq("default idle_after", c.idle_after, 300); eq("default deep_after", c.deep_after, DAY)
	eq("default poll", c.poll, 10); eq("default deep poll", c.deep_poll, 30); eq("default notice", c.notice_every, WEEK)
	c = assert(it.parse_config(env({ DUNE_IDLE_FPS = "7", DUNE_ACTIVE_FPS = "30", DUNE_IDLE_AFTER = "60", DUNE_IDLE_POLL = "5",
		DUNE_DEEP_IDLE_FPS = "2", DUNE_DEEP_IDLE_AFTER = "3600", DUNE_DEEP_IDLE_POLL = "20", DUNE_DEEP_IDLE_NOTICE = "0",
		DUNE_WORLD_DISPLAY_NAME = "My World" })))
	eq("idle set", c.idle_fps, 7); eq("active set", c.active_fps, 30); eq("idle_after set", c.idle_after, 60)
	eq("poll set", c.poll, 5); eq("deep set", c.deep_fps, 2); eq("deep_after set", c.deep_after, 3600)
	eq("deep poll set", c.deep_poll, 20); eq("notice off", c.notice_every, 0); eq("world name", c.world_name, "My World")
	-- The switch, as a classifier over the values an operator might write.
	for v, want in pairs({ ["0"] = false, off = false, ["false"] = false, no = false, ["1"] = true, on = true, ["true"] = true, yes = true, [""] = true }) do
		local cc = it.parse_config(env({ DUNE_IDLE_THROTTLE = v }))
		eq("switch " .. v, cc and cc.enabled, want)
	end
	eq("switch garbage rejected", (it.parse_config(env({ DUNE_IDLE_THROTTLE = "maybe" }))), nil)
	-- Every bad value is rejected with a message naming the variable; 0 fps would mean unlimited to the engine.
	local bad = {
		{ DUNE_IDLE_FPS = "0" }, { DUNE_IDLE_FPS = "-1" }, { DUNE_IDLE_FPS = "2.5" }, { DUNE_IDLE_FPS = "five" },
		{ DUNE_ACTIVE_FPS = "0" }, { DUNE_DEEP_IDLE_FPS = "0" }, { DUNE_IDLE_POLL = "0" }, { DUNE_DEEP_IDLE_POLL = "0" },
		{ DUNE_IDLE_AFTER = "-5" }, { DUNE_DEEP_IDLE_NOTICE = "-1" },
		{ DUNE_IDLE_FPS = "25" },                         -- idle above active
		{ DUNE_DEEP_IDLE_FPS = "6" },                     -- deep above idle
		{ DUNE_DEEP_IDLE_AFTER = "200" },                 -- deep before idle
	}
	for _, b in ipairs(bad) do
		local k = next(b)
		local cc, err = it.parse_config(env(b))
		if cc then fail("accepted " .. k .. "=" .. b[k]) end
		if cc == nil and not (err or ""):find(k:gsub("^DUNE_", ""), 1, true) then fail("error for " .. k .. "=" .. b[k] .. " does not name it: " .. tostring(err)) end
	end
	eq("idle_after 0 allowed", it.parse_config(env({ DUNE_IDLE_AFTER = "0" })) ~= nil, true)
	eq("equal tiers allowed", it.parse_config(env({ DUNE_IDLE_FPS = "20", DUNE_DEEP_IDLE_FPS = "20" })) ~= nil, true)
end

-- Connection counting from `ss -Htn state established` ------------------------------------------------------------
do
	local P = 31982
	-- Classifier over a set of lines: which count as a player connection to the broker port.
	local lines = {
		{ "0      0      192.0.2.10:31982 198.51.100.7:50122", true },
		{ "0      0      [::ffff:192.0.2.10]:31982 [::ffff:198.51.100.7]:50122", true },
		{ "0      0      [2001:db8::1]:31982 [2001:db8::2]:40000", true },
		{ "0      0      100.64.0.10:31982 100.64.0.11:40000", true },
		{ "0      0      127.0.0.1:31982 127.0.0.1:37078", false },
		{ "0      0      192.0.2.10:31982 127.0.0.1:37078", false },
		{ "0      0      127.0.0.1:31982 127.12.0.5:1234", false },
		{ "0      0      [::1]:31982 [::1]:40000", false },
		{ "0      0      [::ffff:127.0.0.1]:31982 [::ffff:127.0.0.1]:40000", false },
		{ "0      0      192.0.2.10:5674 198.51.100.7:50122", false },   -- another local port
		{ "0      0      198.51.100.7:50122 192.0.2.10:31982", false },  -- we are the client, not the broker
		{ "0      0      192.0.2.10:319820 198.51.100.7:50122", false },
		{ "", false }, { "garbage", false },
		{ "ESTAB  0      0      192.0.2.10:31982 198.51.100.7:50123 users:((\"beam.smp\",pid=1,fd=2))", true },
	}
	local all = {}
	for _, l in ipairs(lines) do
		eq("counts " .. l[1], it.count_connections(l[1] .. "\n", P), l[2] and 1 or 0)
		all[#all + 1] = l[1]
	end
	eq("counts the whole set", it.count_connections(table.concat(all, "\n"), P), 5)
	eq("nil text", it.count_connections(nil, P), 0)
end

-- Decision sequences ---------------------------------------------------------------------------------------------
local CFG = assert(it.parse_config(env({ DUNE_WORLD_DISPLAY_NAME = "Test World" })))
local SERVER = "4242"

-- Drive the decision from t0 to t1, advancing time by the poll interval it asks for. conn(t) gives the connection
-- count (or false for "map server down"); ok(action, t) says whether carrying out an action succeeded.
-- Returns the log of actions as strings "t:set N" / "t:notify", the final state and the polls seen.
local function drive(o)
	local cfg = o.cfg or CFG
	local t = o.t0 or 0
	local st = o.state or it.initial_state(t, cfg, o.persisted, SERVER)
	local log, polls, events = {}, {}, {}
	while t <= o.t1 do
		local n = 0
		if o.conn then n = o.conn(t) end
		local obs = { connections = n or 0, server = (n ~= false) and (o.server and o.server(t) or SERVER) or nil }
		local action, poll, ev
		st, action, poll, ev = it.step(st, obs, t, cfg)
		for _, e in ipairs(ev) do events[#events + 1] = t .. ":" .. e end
		if action then
			local good = not o.ok or o.ok(action, t)
			if action.set_fps then
				log[#log + 1] = t .. ":set " .. action.set_fps
				st = it.applied(st, action, good, t)
			elseif action.notify then
				log[#log + 1] = t .. ":notify"
				st = it.notified(st, good, t)
			end
			if o.on_action then o.on_action(action, t) end
		end
		polls[#polls + 1] = poll
		t = t + poll
	end
	return table.concat(log, ","), st, polls, events
end

do
	-- Stays active while connected: nothing is ever sent, polls stay short.
	local log, _, polls = drive({ t1 = 2 * DAY, conn = function() return 1 end })
	eq("connected: no actions", log, "")
	local all10 = true
	for _, p in ipairs(polls) do if p ~= 10 then all10 = false end end
	eq("connected: poll 10", all10, true)

	-- Nobody from startup: idle after 300 s, deep idle after 24 h; each sent once; deep polls every 30 s.
	local seen
	log, _, polls = drive({ t1 = DAY + 100, conn = function() return 0 end, on_action = function(a, t) if t == 300 then seen = a.message end end })
	eq("idle tiers", log, "300:set 5,86400:set 1")
	eq("throttle message", seen, "throttled to 5 fps (idle 300 s)")
	eq("deep poll after deep idle", polls[#polls], 30)
	local _, _, p2 = drive({ t1 = 400, conn = function() return 0 end })
	eq("idle tier still polls 10", p2[#p2], 10)
	local deep_msg
	drive({ t1 = DAY, conn = function() return 0 end, on_action = function(a) deep_msg = a.message end })
	eq("deep message", deep_msg, "throttled to 1 fps (deep idle, idle 86400 s)")

	-- A blip of a connection resets the idle timer.
	log = drive({ t1 = 1000, conn = function(t) return t == 290 and 1 or 0 end })
	eq("blip resets idle timer", log, "600:set 5")

	-- Restore at once on the first connection, from either tier, then the short poll; idle starts over afterwards.
	local restore_msg
	log = drive({ t1 = 1200, conn = function(t) return (t >= 400 and t < 500) and 2 or 0 end,
		on_action = function(a, t) if t == 400 then restore_msg = a.message end end })
	eq("restore from idle", log, "300:set 5,400:set 20,800:set 5")
	eq("restore message (plural)", restore_msg, "restored 20 fps (2 connections)")
	local one
	drive({ t1 = 500, conn = function(t) return t >= 400 and 1 or 0 end, on_action = function(a, t) if t == 400 then one = a.message end end })
	eq("restore message (singular)", one, "restored 20 fps (1 connection)")
	local back = DAY + 1000
	log, _, polls = drive({ t1 = back + 400, conn = function(t) return (t >= back and t < back + 30) and 1 or 0 end })
	-- deep polls are 30 s from 86400, so the connection is first seen at the first poll at or after `back`.
	local first_seen = DAY + math.ceil((back - DAY) / 30) * 30
	eq("restore from deep idle, then idle again after 300 s (not deep)", log,
		"300:set 5,86400:set 1," .. first_seen .. ":set 20," .. (first_seen + 310) .. ":set 5")

	-- Poll interval follows the tier: short again as soon as a connection restores the active rate.
	local st = it.initial_state(0, CFG, nil, SERVER)
	local a, p
	st, a = it.step(st, { connections = 0, server = SERVER }, DAY, CFG)
	eq("deep set at once when idle long enough", a and a.set_fps, 1)
	st = it.applied(st, a, true, DAY)
	st, a, p = it.step(st, { connections = 0, server = SERVER }, DAY + 30, CFG)
	eq("deep: no action", a, nil); eq("deep: poll 30", p, 30)
	st, a, p = it.step(st, { connections = 1, server = SERVER }, DAY + 60, CFG)
	eq("connection in deep: restore", a and a.set_fps, 20); eq("connection in deep: poll 10 at once", p, 10)
	st = it.applied(st, a, true, DAY + 60)
	_, a, p = it.step(st, { connections = 1, server = SERVER }, DAY + 70, CFG)
	eq("restored: nothing re-sent", a, nil); eq("restored: poll 10", p, 10)

	-- A failed set is retried at the next poll (the rate is unknown after a failure).
	local fails = 0
	log = drive({ t1 = 330, conn = function() return 0 end, ok = function() fails = fails + 1; return fails > 1 end })
	eq("failed set retried next poll", log, "300:set 5,310:set 5")
	fails = 0
	log = drive({ t1 = 520, conn = function(t) return t >= 500 and 1 or 0 end, ok = function(_, t) if t >= 500 then fails = fails + 1; return fails > 2 end; return true end })
	eq("failed restore retried each poll", log, "300:set 5,500:set 20,510:set 20,520:set 20")

	-- Map server down: nothing is sent, even with a connection and the rate lowered.
	log = drive({ t1 = 900, conn = function(t) if t >= 400 and t < 500 then return false end; return 0 end })
	eq("no server: nothing sent; a new server gets the full grace", log, "300:set 5,800:set 5")

	-- A new map server (pid change) starts at the game's default: assume active, wait idle_after before lowering.
	log = drive({ t1 = 1000, conn = function() return 0 end, server = function(t) return t >= 400 and "5555" or SERVER end })
	eq("server restart: grace, then idle again", log, "300:set 5,700:set 5")
end

-- Startup and restart ---------------------------------------------------------------------------------------------
do
	-- Fresh start: assumes the active rate, changes nothing until idle_after has elapsed.
	local log = drive({ t0 = 1000, t1 = 1290, conn = function() return 0 end })
	eq("fresh start: nothing before idle_after", log, "")
	-- Restart with persisted state for the same map server: trusted as is.
	local persisted = { server = SERVER, applied = 1, idle_since = 0, deep_since = DAY, last_notice = nil }
	local _, _, polls = drive({ t0 = DAY + 5000, t1 = DAY + 5600, persisted = persisted, conn = function() return 0 end })
	eq("restart in deep idle: nothing re-sent", (drive({ t0 = DAY + 5000, t1 = DAY + 5600, persisted = persisted, conn = function() return 0 end })), "")
	eq("restart in deep idle: deep poll", polls[1], 30)
	log = drive({ t0 = DAY + 5000, t1 = DAY + 5010, persisted = persisted, conn = function() return 1 end })
	eq("restart in deep idle, player connected: restore at once", log, (DAY + 5000) .. ":set 20")
	-- Unknown rate (stopped mid-change) for the same server: a connection restores; idle waits out the grace.
	local unknown = { server = SERVER, idle_since = 0 }
	eq("unknown rate + connection: restore", (drive({ t0 = 1000, t1 = 1000, persisted = unknown, conn = function() return 1 end })), "1000:set 20")
	eq("unknown rate + idle: grace then deep", (drive({ t0 = DAY * 2, t1 = DAY * 2 + 300, persisted = unknown, conn = function() return 0 end })), (DAY * 2 + 300) .. ":set 1")
	-- A different map server since: its rate is the default; the idle clock is kept, the grace applies.
	local other = { server = "999", applied = 1, idle_since = 0, deep_since = DAY }
	eq("other server: grace, then straight to deep", (drive({ t0 = DAY * 2, t1 = DAY * 2 + 300, persisted = other, conn = function() return 0 end })), (DAY * 2 + 300) .. ":set 1")
end

-- Disabled ------------------------------------------------------------------------------------------------------------
do
	local off = assert(it.parse_config(env({ DUNE_IDLE_THROTTLE = "0" })))
	eq("disabled: never lowers", (drive({ cfg = off, t1 = 2 * DAY, conn = function() return 0 end })), "")
	eq("disabled: restores a lowered rate at once", (drive({ cfg = off, t0 = 100, t1 = 200, persisted = { server = SERVER, applied = 5, idle_since = 0 }, conn = function() return 0 end })), "100:set 20")
	local _, _, _, events = drive({ cfg = off, t1 = 100, conn = function(t) return t == 50 and 1 or 0 end })
	eq("disabled: still logs connections", #events, 2)
end

-- Events: connection transitions, for comparing with when a player appears in the world ---------------------------
do
	local _, _, _, events = drive({ t1 = 400, conn = function(t) return (t >= 100 and t < 200) and 1 or 0 end })
	eq("event count", #events, 2)
	eq("first connection event", events[1], "100:first connection (1 connection; nobody connected since 1970-01-01T00:00:00Z)")
	eq("last connection closed event", events[2], "200:nobody connected (was 1 connection)")
	_, _, _, events = drive({ t1 = 30, conn = function(t) return t == 10 and 1 or (t == 20 and 3 or 0) end })
	eq("count change while connected is not an event", #events, 2)
	eq("closed event carries the last count", events[2], "30:nobody connected (was 3 connections)")
end

-- Weekly notice while in deep idle -------------------------------------------------------------------------------------
do
	local notices = {}
	local function collect(a, t) if a.notify then notices[#notices + 1] = { t = t, subject = a.subject, body = a.body } end end
	local log = drive({ t1 = DAY + 2 * WEEK + 60, conn = function() return 0 end, on_action = collect })
	eq("notices weekly from entering deep idle", log, "300:set 5,86400:set 1," .. (DAY + WEEK) .. ":notify," .. (DAY + 2 * WEEK) .. ":notify")
	eq("notice subject", notices[1] and notices[1].subject, "Test World: still up, nobody connected since 1970-01-01T00:00:00Z")
	local body = notices[1] and notices[1].body or ""
	if not (body:find("1970-01-01T00:00:00Z", 1, true) and body:find("8 days", 1, true) and body:find("1 fps", 1, true) and body:find("Test World", 1, true)) then
		fail("notice body lacks idle start, duration, rate or world: " .. body)
	end
	-- A failed notice is retried at the next poll, not dropped; the weekly clock follows the successful one.
	local tries = 0
	log = drive({ t1 = DAY + 2 * WEEK + 60, conn = function() return 0 end,
		ok = function(a) if a.notify then tries = tries + 1; return tries > 2 end; return true end })
	eq("failed notice retried", log, "300:set 5,86400:set 1," .. (DAY + WEEK) .. ":notify," .. (DAY + WEEK + 30) .. ":notify," ..
		(DAY + WEEK + 60) .. ":notify," .. (DAY + 2 * WEEK + 60) .. ":notify")
	-- Leaving deep idle resets it: the next deep stretch starts its own week.
	local back = DAY + 3 * DAY
	log = drive({ t1 = back + DAY + WEEK + 400, conn = function(t) return (t >= back and t < back + 30) and 1 or 0 end })
	local seen_back = DAY + math.ceil((back - DAY) / 30) * 30
	local prefix = "300:set 5,86400:set 1," .. seen_back .. ":set 20,"
	eq("connection before a week: no notice in the first stretch", log:sub(1, #prefix), prefix)
	eq("one notice in the second deep stretch", select(2, log:gsub("notify", "")), 1)
	local notice_t = tonumber(log:match("(%d+):notify"))
	eq("second stretch's notice a week after its deep idle began", notice_t and notice_t > back + DAY + WEEK and notice_t <= back + DAY + WEEK + 400, true)
	-- Notices off.
	local quiet = assert(it.parse_config(env({ DUNE_DEEP_IDLE_NOTICE = "0" })))
	eq("notice 0: none", select(2, (drive({ cfg = quiet, t1 = DAY + 3 * WEEK, conn = function() return 0 end })):gsub("notify", "")), 0)
	-- A set takes priority; a notice is never sent while a connection is present.
	local st = it.initial_state(0, CFG, { server = SERVER, applied = 1, idle_since = 0, deep_since = DAY }, SERVER)
	local _, a = it.step(st, { connections = 1, server = SERVER }, DAY + WEEK + 5, CFG)
	eq("connection: restore, not notice", a and a.set_fps, 20)
end

-- Persistence --------------------------------------------------------------------------------------------------------
do
	local _, st = drive({ t1 = DAY + WEEK + 10, conn = function() return 0 end })
	local text = it.encode(st)
	local p = it.decode(text)
	eq("persist server", p.server, SERVER); eq("persist applied", p.applied, 1); eq("persist idle_since", p.idle_since, 0)
	eq("persist deep_since", p.deep_since, DAY); eq("persist last_notice", p.last_notice, DAY + WEEK)
	-- A component restart keeps the weekly clock: no notice at once, the next one a week after the last.
	local log = drive({ t0 = DAY + WEEK + 5000, t1 = DAY + 2 * WEEK + 20, persisted = p, conn = function() return 0 end })
	eq("restart keeps the weekly clock", log, (DAY + 2 * WEEK + 20 - ((DAY + 2 * WEEK + 20 - (DAY + WEEK + 5000)) % 30)) .. ":notify")
	-- The start grace only holds back lowering the rate: a notice already due at a restart goes out at once.
	local due = { server = SERVER, applied = 1, idle_since = 0, deep_since = DAY, last_notice = DAY + WEEK }
	eq("notice due at restart is not held by the grace", (drive({ t0 = DAY + 2 * WEEK, t1 = DAY + 2 * WEEK, persisted = due, conn = function() return 0 end })),
		(DAY + 2 * WEEK) .. ":notify")
	-- Without a display name the notice still reads well.
	local unnamed = assert(it.parse_config(env({})))
	local _, a = it.step(it.initial_state(0, unnamed, due, SERVER), { connections = 0, server = SERVER }, DAY + 2 * WEEK, unnamed)
	eq("unnamed subject", a and a.subject, "Dune world: still up, nobody connected since 1970-01-01T00:00:00Z")
	eq("unnamed body", a and a.body and a.body:sub(1, 42), "The Dune: Awakening world is still up. Nob")
	-- Unknown rate persists as unknown; garbage and missing fields are ignored.
	local u = it.decode(it.encode(it.applied(st, { set_fps = 5, tier = "idle" }, false, 1)))
	eq("unknown persists", u.applied, nil); eq("unknown keeps server", u.server, SERVER)
	local g = it.decode("junk\napplied=abc\nidle_since=\nserver=12\nlast_notice=7\n")
	eq("garbage applied ignored", g.applied, nil); eq("empty idle_since ignored", g.idle_since, nil)
	eq("garbage file keeps valid fields", g.server, "12"); eq("garbage file last_notice", g.last_notice, 7)
	eq("decode nil", next(it.decode(nil)), nil)
end

if failures > 0 then io.stderr:write(failures, " failure(s)\n"); os.exit(1) end
