-- Pure logic of the in-game chat command bridge (libexec/dune-gm-bridge): turn a chat delivery from the game broker's
-- chat.intercept exchange into a sender and text, parse `&command args`, authorize it against the operator's policy
-- (gm_bridge.conf) and plan dune-live argv arrays plus a reply. No I/O here; item names come in as a db from lib/items.lua.
-- Trust model: the only sender identity is the AMQP user_id the broker stamps (RabbitMQ rejects a publish whose
-- user_id differs from the connection's user, the player's FLS id); the Funcom id in the routing key and body is
-- client-supplied and ignored. Unknown senders, missing policy and malformed input all deny (fail closed).
local cjson = require("cjson.safe")
local items = require("items")
local M = {}
M.NOT_ALLOWED = "not allowed"
-- Permissions a policy line can grant. give puts items into your own inventory; give-others into another player's;
-- water and water-others likewise refill water containers, fuel and fuel-others hand out vehicle fuel cells, unlock and unlock-others open a school's skill tree;
-- thufir sends a message to the operator's assistant.
M.COMMANDS = { "bring", "fuel", "fuel-others", "give", "give-others", "goto", "kick", "say", "thufir", "timeout", "unlock", "unlock-others", "water",
	"water-others", "where" }
-- Longest &thufir message passed on (chat lines are shorter; this only bounds a hostile client).
local MAX_NOTE = 2000
-- Amount &water asks dune-live to put into the player's containers: more than any loadout holds, so every container
-- ends up full (the game caps each at its capacity).
M.WATER_FILL = "100000"
-- &fuel: large vehicle fuel cells (the game's vehicle "battery"; one refuelled a sandbike, verified) per request.
-- No server command fills a vehicle's tank, so the player loads a cell themselves.
M.FUEL_ITEM, M.FUEL_COUNT = "FuelCanister_Large", "5"
local KNOWN = { help = true }
for _, c in ipairs(M.COMMANDS) do KNOWN[c] = true end
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

local GIVE_USAGE = "&give <item name or id> [count] [to <player>]"
local FULL_INVENTORY = "; a full inventory can drop items"

-- parse_give(cmd) -> {item, count (string or nil), target (nil = the sender)} or nil for a usage error. The target is
-- everything after the last standalone `to` (any case); a standalone whole number before it is always the count, so
-- names containing numbers are typed hyphenated (karpov-38).
function M.parse_give(cmd)
	local s = " " .. (cmd.rest or "") .. " "
	local cut, target
	local from = 1
	while true do
		local i, j = s:lower():find("%sto%s", from)
		if not i then break end
		cut, target, from = i, s:sub(j + 1), j
	end
	local head = cut and s:sub(1, cut) or s
	if target then
		target = trim(target)
		if target == "" then return nil end
	end
	local item, count = trim(head), nil

	local before, n = item:match("^(.-)%s+(%d+)$")
	if before then item, count = before, n end
	if item == "" or item:match("^%d+$") then return nil end
	return { item = item, count = count, target = target }
end

-- permission(cmd, me) -> the policy permission cmd needs when sent by character me: give-others for a give to
-- anyone but me, else the command's own name.
-- School names &unlock accepts, as words (dune-live's unlock-tree normalizes them); longest first so "bene gesserit"
-- wins over a shorter prefix.
local SCHOOLS = { "bene gesserit", "benegesserit", "planetologist", "swordmaster", "trooper", "mentat", "sword", "bg" }

-- parse_unlock(cmd) -> {school, target|nil} for `&unlock <school> [to|for] [player]`: the known school name at the start
-- (any case and spacing), then an optional player, with or without `to`/`for`. nil for an unknown school or an empty
-- player after `to`/`for`.
function M.parse_unlock(cmd)
	local rest, lower = cmd.rest, cmd.rest:lower()
	for _, name in ipairs(SCHOOLS) do
		local pat = "^" .. name:gsub(" ", "%%s+") .. "()"
		local e = lower:match(pat)
		if e and (e > #lower or lower:sub(e, e):match("%s")) then
			local after = rest:sub(e):match("^%s*(.-)%s*$")
			local word, who = after:match("^(%S+)%s*(.*)$")
			if word and (word:lower() == "to" or word:lower() == "for") then
				if who == "" then return nil end
				after = who
			end
			return { school = rest:sub(1, e - 1), target = after ~= "" and after or nil }
		end
	end
	return nil
end

function M.permission(cmd, me)
	if cmd.name == "give" then
		local g = M.parse_give(cmd)
		if g and g.target and g.target ~= me then return "give-others" end
	elseif (cmd.name == "water" or cmd.name == "fuel") and cmd.rest ~= "" and cmd.rest ~= me then
		return cmd.name .. "-others"
	elseif cmd.name == "unlock" then
		local u = M.parse_unlock(cmd)
		if u and u.target and u.target ~= me then return "unlock-others" end
	end
	return cmd.name
end

local function usage(r) return { actions = {}, reply = "usage: " .. r } end
-- A value passed to dune-live: non-empty, bounded, no control characters, and not option-like (dune-live treats
-- -h/--help/--json anywhere as its own options).
local function ok_arg(s) return s and s ~= "" and #s <= MAX_ARG and not s:find("%c") and s:sub(1, 1) ~= "-" end


-- plan(cmd, sender = {fls, name, origin}, policy, item_db) -> {actions = {argv...}, reply}. argv arrays are dune-live
-- arguments; the caller runs them without a shell. Authorization is the caller's job (see authorize and permission).
-- item_db (lib/items.lua build) is needed only for give.
function M.plan(cmd, sender, policy, item_db)
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
	elseif n == "thufir" then
		if cmd.rest == "" or #cmd.rest > MAX_NOTE then return usage("&thufir <message>") end
		return { actions = {}, note = { from = me, text = cmd.rest }, reply = "sent to Thufir" }
	elseif n == "unlock" then
		local u = M.parse_unlock(cmd)
		if not u or not ok_arg(u.school) or (u.target and not ok_arg(u.target)) then return usage("&unlock <school> [to <player>]") end
		local who = u.target or me
		return { actions = { { "character", "unlock-tree", who, u.school } }, reply = "opened the " .. u.school .. " tree" .. (who == me and "" or (" for " .. who)) }
	elseif n == "water" then
		local who = cmd.rest ~= "" and cmd.rest or me
		if not ok_arg(who) then return usage("&water [player]") end
		return { actions = { { "character", "water", who, M.WATER_FILL } }, reply = who == me and "water refilled" or ("refilled " .. who .. "'s water") }
	elseif n == "fuel" then
		local who = cmd.rest ~= "" and cmd.rest or me
		if not ok_arg(who) then return usage("&fuel [player]") end
		return { actions = { { "character", "give", who, M.FUEL_ITEM, M.FUEL_COUNT } },
			reply = string.format("gave %s %s large vehicle fuel cells; load one into the vehicle to refuel it%s", who == me and "you" or who, M.FUEL_COUNT, FULL_INVENTORY) }
	elseif n == "give" then
		local g = M.parse_give(cmd)
		if not g or (g.target and not ok_arg(g.target)) then return usage(GIVE_USAGE) end
		if g.count and tonumber(g.count) < 1 then return usage(GIVE_USAGE) end
		local r = items.resolve(item_db, g.item)
		local function label(it) return string.format("%s (%s)", items.display(it.name), it.id) end
		if not r.item then
			local c = r.candidates or {}
			local list = {}
			for i, it in ipairs(c) do list[i] = label(it) end
			local tail = (r.more or 0) > 0 and string.format(", and %d more", r.more) or ""
			if r.ambiguous then
				return { actions = {}, reply = string.format('several items are named "%s": %s%s; give one by id', g.item, table.concat(list, ", "), tail) }
			elseif #c > 0 then
				return { actions = {}, reply = string.format('no item "%s"; did you mean: %s%s?', g.item, table.concat(list, ", "), tail) }
			end
			return { actions = {}, reply = string.format('no item "%s"; try another name or an item id', g.item) }
		end
		local it = r.item
		-- The cap per give (lib/items.lua): the curated max count, else the stack size (at least 10), else 1000.
		local count, max = tonumber(g.count or "1"), it.cap
		if count > max then return { actions = {}, reply = string.format("at most %d %s per give", max, label(it)) } end
		local who = g.target or me
		local note = it.raw and " (not in the item list; nothing arrives if the game does not know it)"
			or it.verified == false and string.format(" (%s, id not yet verified in game)", it.id)
			or string.format(" (%s)", it.id)
		return { actions = { { "character", "give", who, it.id, tostring(count) } },
			reply = string.format("gave %s %d %s%s%s", who == me and "you" or who, count, items.display(it.name), note, FULL_INVENTORY) }
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

-- thufir_note(note = {from, text}, datetime, id) -> {name, text}: an llmsend/v1 inbox note (JSON frontmatter between
-- ---json and ---, then a Markdown body) carrying an in-game &thufir message to the operator's assistant, which
-- answers with a whisper. The filename slug keeps only [a-z0-9-] of the character name, so it cannot leave the inbox.
function M.thufir_note(note, datetime, id)
	local slug = note.from:lower():gsub("[^a-z0-9]+", "-"):gsub("^%-+", ""):gsub("%-+$", "")
	if slug == "" then slug = "player" end
	local meta = cjson.encode({ schema = "llmsend/v1", subject = "In-game message from " .. note.from,
		description = "A player sent &thufir in game chat; reply with an in-game whisper.",
		sender = note.from .. " (in game)", recipient = "dune_awakening_server", datetime = datetime,
		message_type = "question", response_expected = true, priority = "normal", tags = { "game", "thufir", "chat" } })
	local body = "# In-game message from " .. note.from .. "\n\n" .. note.text .. "\n\nReply in game: `dune-awakening character whisper "
		.. M.shell_quote(note.from) .. " '<reply>' --from Thufir`\n"
	return { name = datetime:sub(1, 10) .. "-from-game-" .. slug .. "-" .. id .. ".frontmatter.md", text = "---json\n" .. meta .. "\n---\n\n" .. body }
end

return M
