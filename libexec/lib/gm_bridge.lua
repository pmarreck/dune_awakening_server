-- Pure logic of the in-game chat command bridge (libexec/dune-gm-bridge): turn a chat delivery from the game broker's
-- chat.intercept exchange into a sender and text, parse `&command args`, authorize it against the operator's policy
-- (gm_bridge.conf) and plan dune-live argv arrays plus a reply. No I/O here.
-- Trust model: the only sender identity is the AMQP user_id the broker stamps (RabbitMQ rejects a publish whose
-- user_id differs from the connection's user, the player's FLS id); the Funcom id in the routing key and body is
-- client-supplied and ignored. Unknown senders, missing policy and malformed input all deny (fail closed).
local cjson = require("cjson.safe")
local M = {}
M.NOT_ALLOWED = "not allowed"
M.COMMANDS = { "bring", "give", "goto", "kick", "say", "timeout", "where" }
local KNOWN = { help = true }
for _, c in ipairs(M.COMMANDS) do KNOWN[c] = true end
local MAX_GIVE = 1000
local MAX_ARG = 200

local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end

-- parse_delivery(d) -> {sender_fls, channel, text, origin = {x, y, z} or nil}; nil for anything that is not a
-- TextChat message carrying a well-formed broker-stamped user_id (an FLS id: 16 hex digits).
function M.parse_delivery(d)
	local uid = d and d.properties and d.properties.user_id
	if type(uid) ~= "string" or not uid:match("^%x+$") or #uid ~= 16 then return nil end
	local outer = cjson.decode(d.body or "")
	if type(outer) ~= "table" or outer.Type ~= "TextChat" or type(outer.content) ~= "string" then return nil end
	local inner = cjson.decode(outer.content)
	if type(inner) ~= "table" or type(inner.m_Message) ~= "table" then return nil end
	local text = inner.m_Message.m_UnlocalizedMessage
	if type(text) ~= "string" then return nil end
	local o, origin = inner.m_OriginLocation, nil
	if type(o) == "table" and type(o.X) == "number" and type(o.Y) == "number" and type(o.Z) == "number" then
		origin = { x = o.X, y = o.Y, z = o.Z }
	end
	return { sender_fls = uid:upper(), channel = tostring(inner.m_ChannelType or ""), text = text, origin = origin }
end

-- parse_command(text) -> {name, args, rest} for text starting with `&` (after leading spaces); nil otherwise.
function M.parse_command(text)
	local body = type(text) == "string" and text:match("^%s*&(.*)$")
	if not body then return nil end
	local name, rest = body:match("^(%S*)%s*(.-)%s*$")
	local args = {}
	for w in rest:gmatch("%S+") do args[#args + 1] = w end
	name = name:lower()
	return { name = name ~= "" and name or "help", args = args, rest = rest }
end

-- parse_policy(text) -> policy, errors. Lines `<character name or FLS id>: <cmd> <cmd>...` (`*` = every command),
-- `#` comments and blank lines. nil text (no file) gives an empty policy: nobody is authorized.
function M.parse_policy(text)
	local policy, errors = { entries = {} }, {}
	local n = 0
	for line in ((text or "") .. "\n"):gmatch("([^\n]*)\n") do
		n = n + 1
		local l = trim(line:gsub("\r$", ""))
		if l ~= "" and l:sub(1, 1) ~= "#" then
			local who, cmds = l:match("^([^:]+):(.*)$")
			who = who and trim(who)
			if not who or who == "" then
				errors[#errors + 1] = string.format("line %d: expected `<character name or FLS id>: <command>...`", n)
			else
				local set = {}
				for c in cmds:gmatch("%S+") do
					c = c:lower()
					if c == "*" or KNOWN[c] then set[c] = true
					else errors[#errors + 1] = string.format("line %d: unknown command %s", n, c) end
				end
				policy.entries[#policy.entries + 1] = { who = who, cmds = set }
			end
		end
	end
	return policy, errors
end

local function is_fls(s) return #s == 16 and s:match("^%x+$") ~= nil end

-- The policy entries that apply to a sender: an entry shaped like an FLS id matches that account (any case) and
-- nothing else, so a character named like an id gains nothing; any other entry matches the character name exactly.
local function entries_for(policy, fls, name)
	local out = {}
	for _, e in ipairs(policy and policy.entries or {}) do
		if is_fls(e.who) then
			if e.who:upper() == fls then out[#out + 1] = e end
		elseif name and e.who == name then
			out[#out + 1] = e
		end
	end
	return out
end

-- authorize(policy, fls, name, cmd): true only when an entry for this sender grants cmd (or `*`). help is granted
-- to anyone with an entry; unknown commands never are.
function M.authorize(policy, fls, name, cmd)
	if not KNOWN[cmd] or type(fls) ~= "string" then return false end
	local es = entries_for(policy, fls:upper(), name)
	if #es == 0 then return false end
	if cmd == "help" then return true end
	for _, e in ipairs(es) do if e.cmds["*"] or e.cmds[cmd] then return true end end
	return false
end

local function usage(r) return { actions = {}, reply = "usage: " .. r } end
-- A value passed to dune-live: non-empty, bounded, no control characters, and not option-like (dune-live treats
-- -h/--help/--json anywhere as its own options).
local function ok_arg(s) return s and s ~= "" and #s <= MAX_ARG and not s:find("%c") and s:sub(1, 1) ~= "-" end


-- plan(cmd, sender = {fls, name, origin}, policy) -> {actions = {argv...}, reply}. argv arrays are dune-live
-- arguments; the caller runs them without a shell. Authorization is the caller's job (see authorize).
function M.plan(cmd, sender, policy)
	local me = sender.name
	local n = cmd.name
	if n == "help" then
		local list = {}
		for _, c in ipairs(M.COMMANDS) do if M.authorize(policy, sender.fls, me, c) then list[#list + 1] = c end end
		return { actions = {}, reply = "commands: " .. table.concat(list, ", ") }
	elseif n == "where" then
		local o = sender.origin
		if not o then return { actions = {}, reply = "your position is unknown" } end
		local function r(v) return string.format("%d", math.floor(v + 0.5)) end
		return { actions = {}, reply = string.format("you are at X %s Y %s Z %s", r(o.x), r(o.y), r(o.z)) }
	elseif n == "goto" or n == "bring" then
		local who = cmd.rest
		if not ok_arg(who) or who == me then return usage("&" .. n .. " <player> (another player)") end
		if n == "goto" then return { actions = { { "character", "move", me, "to", who } }, reply = "moving you to " .. who } end
		return { actions = { { "character", "move", who, "to", me } }, reply = "bringing " .. who .. " to you" }
	elseif n == "say" then
		if not ok_arg(cmd.rest) then return usage("&say <message>") end
		return { actions = { { "world", "say", cmd.rest } }, reply = "announced" }
	elseif n == "timeout" then
		local a = (cmd.args[1] or "status"):lower()
		if #cmd.args > 1 or not (a == "on" or a == "off" or a == "status") then return usage("&timeout on|off|status") end
		return { actions = { { "world", "timeout", a } }, reply = "timeout " .. a }
	elseif n == "give" then
		local item, count = cmd.args[1], cmd.args[2] or "1"
		if #cmd.args < 1 or #cmd.args > 2 or not item:match("^[%w_]+$") or not count:match("^%d+$")
			or tonumber(count) < 1 or tonumber(count) > MAX_GIVE then
			return usage("&give <item id> [count 1-" .. MAX_GIVE .. "]")
		end
		return { actions = { { "character", "give", me, item, tostring(tonumber(count)) } }, reply = "gave you " .. count .. " " .. item }
	elseif n == "kick" then
		if not ok_arg(cmd.rest) then return usage("&kick <player>") end
		return { actions = { { "character", "kick", cmd.rest } }, reply = "kicked " .. cmd.rest }
	end
	return { actions = {}, reply = "unknown command; try &help" }
end

-- The log line for one command (only `&` commands are ever logged; ordinary chat never is).
function M.log_line(fls, name, text, verdict)
	return string.format("%s %s %s: %s", fls, name or "?", verdict, (text:gsub("%c", " ")))
end

-- shell_quote(s): s as one POSIX-shell word (single quotes, each ' written as '\''), so a shell passes it on verbatim.
function M.shell_quote(s) return "'" .. tostring(s):gsub("'", "'\\''") .. "'" end
-- command_line(argv): every element quoted, for io.popen; no element is ever interpreted by the shell.
function M.command_line(argv)
	local parts = {}
	for i, a in ipairs(argv) do parts[i] = M.shell_quote(a) end
	return table.concat(parts, " ")
end

return M
