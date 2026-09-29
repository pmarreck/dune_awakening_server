-- idle_throttle: pure logic of the idle frame-rate throttle (libexec/dune-idle-throttle does the I/O). Lowers the map
-- server's frame cap (t.MaxFPS) in two tiers while nobody is connected, active -> idle -> deep idle, and restores it on
-- the first connection. Presence = TCP connections to the game broker's TLS port from non-loopback peers (from
-- `ss -Htn state established`). A state machine over (state, observation, now, config) with an injected clock; the
-- caller reports each action's outcome back (applied / notified), so a failed change is retried at the next poll.
local M = {}

local DAY = 86400

-- Configuration: DUNE_* environment variables (bin/dune-awakening fills them from world.conf keys without the prefix).
local SETTINGS = {
	{ "active_fps", "ACTIVE_FPS", 20, 1 }, { "idle_fps", "IDLE_FPS", 5, 1 }, { "deep_fps", "DEEP_IDLE_FPS", 1, 1 },
	{ "idle_after", "IDLE_AFTER", 300, 0 }, { "deep_after", "DEEP_IDLE_AFTER", DAY, 0 },
	{ "poll", "IDLE_POLL", 10, 1 }, { "deep_poll", "DEEP_IDLE_POLL", 30, 1 }, { "notice_every", "DEEP_IDLE_NOTICE", 7 * DAY, 0 },
}
local SWITCH = { ["0"] = false, off = false, ["false"] = false, no = false, ["1"] = true, on = true, ["true"] = true, yes = true }

-- Parse and validate the settings; get(name) returns an environment value or nil. Returns config or nil, message.
-- A frame cap must be >= 1 (0 means unlimited to the engine) and the tiers must not raise the rate.
function M.parse_config(get)
	local c = {}
	local sw = get("DUNE_IDLE_THROTTLE")
	if sw == nil or sw == "" then c.enabled = true
	elseif SWITCH[sw:lower()] ~= nil then c.enabled = SWITCH[sw:lower()]
	else return nil, "IDLE_THROTTLE must be 1 or 0 (on/off), got " .. sw end
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
	if c.idle_fps > c.active_fps then return nil, string.format("IDLE_FPS (%d) must not exceed ACTIVE_FPS (%d)", c.idle_fps, c.active_fps) end
	if c.deep_fps > c.idle_fps then return nil, string.format("DEEP_IDLE_FPS (%d) must not exceed IDLE_FPS (%d)", c.deep_fps, c.idle_fps) end
	if c.deep_after < c.idle_after then
		return nil, string.format("DEEP_IDLE_AFTER (%d) must not be less than IDLE_AFTER (%d)", c.deep_after, c.idle_after)
	end
	local w = get("DUNE_WORLD_DISPLAY_NAME")
	c.world_name = (w and w ~= "") and w or nil
	return c
end

-- Loopback peers are the world's own components (TextRouter, Director, map server, GM bridge).
local function is_loopback(host)
	host = host:gsub("^%[", ""):gsub("%]$", ""):gsub("%%.*$", ""):lower()
	host = host:gsub("^::ffff:", "")
	return host == "::1" or host:match("^127%.%d+%.%d+%.%d+$") ~= nil
end

-- Count established connections to local `port` from non-loopback peers in `ss -Htn` output (with or without the
-- state column). Each line's first two addr:port fields are the local and peer ends.
function M.count_connections(text, port)
	local n, want = 0, tostring(port)
	for line in (text or ""):gmatch("[^\n]+") do
		local ends = {}
		for f in line:gmatch("%S+") do
			local host, p = f:match("^(.+):(%d+)$")
			if host and #ends < 2 then ends[#ends + 1] = { host = host, port = p } end
		end
		if #ends == 2 and ends[1].port == want and not is_loopback(ends[2].host) then n = n + 1 end
	end
	return n
end

function M.format_time(t) return os.date("!%Y-%m-%dT%H:%M:%SZ", t) end

local function plural(n, word) return n .. " " .. word .. (n == 1 and "" or "s") end

local function copy(t) local r = {}; for k, v in pairs(t) do r[k] = v end; return r end

-- State at component start. `persisted` (from decode) keeps the idle clocks across a component restart, and its
-- believed rate when it was written for the same map server (`server` = its pid); a different or new map server runs
-- at the game's default, taken as the active rate. Nothing is lowered until idle_after after this start (grace).
function M.initial_state(now, cfg, persisted, server)
	local p = persisted or {}
	local s = { started = now, server = server, connected = false, count = 0, applied = cfg.active_fps,
		idle_since = p.idle_since or now }
	if p.idle_since then s.deep_since, s.last_notice = p.deep_since, p.last_notice end
	if persisted and p.server ~= nil and p.server == server then s.applied = p.applied end
	return s
end

local function tier_of(idle_for, cfg)
	if idle_for >= cfg.deep_after then return "deep", cfg.deep_fps end
	if idle_for >= cfg.idle_after then return "idle", cfg.idle_fps end
	return "active", cfg.active_fps
end

-- One poll. obs = {connections = n, server = map-server id or nil when it is down}. Returns the new state, an action
-- (nil, {set_fps, tier, message} or {notify, subject, body}), the seconds until the next poll, and log events.
-- Restores are immediate; lowering waits for idle_after of continuous absence and the start grace; a weekly notice
-- runs while the deep tier holds; deep idle polls less often.
function M.step(state, obs, now, cfg)
	local s, events = copy(state), {}
	if obs.server ~= s.server then
		s.server = obs.server
		if obs.server ~= nil then s.applied, s.started = cfg.active_fps, now end
	end
	local n = obs.connections or 0
	if n > 0 then
		if not s.connected then
			events[#events + 1] = string.format("first connection (%s; nobody connected since %s)", plural(n, "connection"),
				M.format_time(s.idle_since or now))
		end
		s.connected, s.count, s.idle_since, s.deep_since, s.last_notice = true, n, nil, nil, nil
		if s.server ~= nil and s.applied ~= cfg.active_fps then
			return s, { set_fps = cfg.active_fps, tier = "active",
				message = string.format("restored %d fps (%s)", cfg.active_fps, plural(n, "connection")) }, cfg.poll, events
		end
		return s, nil, cfg.poll, events
	end
	if s.connected then
		events[#events + 1] = string.format("nobody connected (was %s)", plural(s.count, "connection"))
		s.connected, s.idle_since = false, now
	end
	if s.server == nil then return s, nil, cfg.poll, events end
	if not cfg.enabled then
		if s.applied ~= cfg.active_fps then
			return s, { set_fps = cfg.active_fps, tier = "active", message = string.format("restored %d fps (throttle off)", cfg.active_fps) }, cfg.poll, events
		end
		return s, nil, cfg.poll, events
	end
	local idle_for = now - s.idle_since
	local tier, fps = tier_of(idle_for, cfg)
	-- Deep idle polls less often, from the poll that sets its rate on.
	local poll = tier == "deep" and cfg.deep_poll or cfg.poll
	if tier == "deep" and s.applied == cfg.deep_fps and not s.deep_since then s.deep_since = now end
	-- The start grace holds back rate changes only; a notice that is due still goes out.
	if fps ~= s.applied and now - s.started >= cfg.idle_after then
		local message
		if tier == "deep" then message = string.format("throttled to %d fps (deep idle, idle %d s)", fps, idle_for)
		elseif tier == "idle" then message = string.format("throttled to %d fps (idle %d s)", fps, idle_for)
		else message = string.format("restored %d fps", fps) end
		return s, { set_fps = fps, tier = tier, message = message }, poll, events
	end
	if s.deep_since and cfg.notice_every > 0 and now >= (s.last_notice or s.deep_since) + cfg.notice_every then
		local since = M.format_time(s.idle_since)
		return s, { notify = true,
			subject = string.format("%s: still up, nobody connected since %s", cfg.world_name or "Dune world", since),
			body = string.format("The Dune: Awakening world%s is still up. Nobody has connected since %s (%d days). " ..
				"The map server has been at %d fps since %s.", cfg.world_name and (" " .. cfg.world_name) or "", since,
				math.floor(idle_for / DAY), cfg.deep_fps,
				M.format_time(s.deep_since)) }, poll, events
	end
	return s, nil, poll, events
end

-- Outcome of a set_fps action: on success the rate is known (entering the deep tier starts its notice clock); on
-- failure it is unknown, so the next poll sends the wanted rate again.
function M.applied(state, action, ok, now)
	local s = copy(state)
	if ok then
		s.applied = action.set_fps
		if action.tier == "deep" and not s.deep_since then s.deep_since = now end
	else
		s.applied = nil
	end
	return s
end

-- Outcome of a notice: the weekly clock moves only on success, so a failure is retried at the next poll.
function M.notified(state, ok, now)
	local s = copy(state)
	if ok then s.last_notice = now end
	return s
end

local PERSISTED = { server = "string", applied = "number", idle_since = "number", deep_since = "number", last_notice = "number" }
local ORDER = { "server", "applied", "idle_since", "deep_since", "last_notice" }

-- key=value lines for the component's state file; an unknown rate is written as applied=unknown.
function M.encode(state)
	local out = {}
	for _, k in ipairs(ORDER) do
		local v = state[k]
		if k == "applied" and v == nil then v = "unknown" end
		if v ~= nil then out[#out + 1] = k .. "=" .. tostring(v) end
	end
	return table.concat(out, "\n") .. "\n"
end

-- Inverse of encode; malformed lines and values are ignored.
function M.decode(text)
	local p = {}
	for line in (text or ""):gmatch("[^\n]+") do
		local k, v = line:match("^([%w_]+)=(.+)$")
		if k and PERSISTED[k] == "string" then p[k] = v
		elseif k and PERSISTED[k] == "number" and v:match("^%-?%d+$") then p[k] = tonumber(v) end
	end
	return p
end

return M
