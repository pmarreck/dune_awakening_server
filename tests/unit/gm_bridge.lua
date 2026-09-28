-- Unit tests for libexec/lib/gm_bridge.lua (run by tests/unit/gm-bridge). Names and ids are synthetic.
package.path = "libexec/lib/?.lua;" .. package.path
local gm = require("gm_bridge")
local cjson = require("cjson")
local failures = 0
local function fail(msg) io.stderr:write("FAIL ", msg, "\n"); failures = failures + 1 end
local function eq(name, got, want)
	if got ~= want then fail(string.format("%s: got %s, want %s", name, tostring(got), tostring(want))) end
end
local function same(name, got, want)
	local g, w = cjson.encode(got), cjson.encode(want)
	if g ~= w then fail(name .. ": got " .. g .. ", want " .. w) end
end

local ALICE, BOB, CAROL, DAVE = "0123456789ABCDEF", "FEDCBA9876543210", "00000000000000AA", "00000000000000BB"

local function chat(text, o)
	o = o or {}
	local inner = cjson.encode({ m_Id = "x", m_ChannelType = o.channel or "Proximity", m_bUseSpoofedUserName = false,
		m_FuncomIdFrom = "Alice#1234", m_UserNameTo = "", m_Message = { m_UnlocalizedMessage = text },
		m_Timestamp = "2026.09.28-02.33.56", m_OriginLocation = o.origin or { X = 155566.13, Y = 300580.16, Z = 1590.89 } })
	return { routing_key = "Alice#1234", properties = { user_id = o.user_id == nil and ALICE or o.user_id or nil },
		body = o.body or cjson.encode({ content = inner, Type = o.type or "TextChat" }) }
end

-- Deliveries ---------------------------------------------------------------------------------------------------
do
	local m = gm.parse_delivery(chat("&where"))
	eq("sender is the broker-stamped user_id", m and m.sender_fls, ALICE)
	eq("text", m and m.text, "&where"); eq("channel", m and m.channel, "Proximity")
	eq("origin x", m and m.origin.x, 155566.13)
	-- The Funcom id in the routing key and body is client-supplied: never the identity.
	eq("no user_id: ignored", gm.parse_delivery(chat("&where", { user_id = false })), nil)
	eq("malformed user_id: ignored", gm.parse_delivery(chat("&where", { user_id = "Alice#1234" })), nil)
	eq("not TextChat: ignored", gm.parse_delivery(chat("&where", { type = "Other" })), nil)
	eq("not JSON: ignored", gm.parse_delivery(chat("", { body = "garbage" })), nil)
	eq("content not JSON: ignored", gm.parse_delivery(chat("", { body = cjson.encode({ content = "{", Type = "TextChat" }) })), nil)
	local no_origin = gm.parse_delivery(chat("&where", { origin = "nope" }))
	eq("bad origin kept as nil", no_origin and no_origin.origin, nil)
end

-- Commands -----------------------------------------------------------------------------------------------------
do
	eq("plain chat is not a command", gm.parse_command("hello &goto x"), nil)
	eq("empty", gm.parse_command(""), nil)
	local c = gm.parse_command("  &GoTo   Bob  ")
	eq("name lowercased", c and c.name, "goto"); same("args split", c and c.args, { "Bob" })
	c = gm.parse_command("&say Restart   in 5")
	eq("rest keeps spacing", c and c.rest, "Restart   in 5")
	eq("bare & is help", gm.parse_command("&").name, "help")
end

-- Policy -------------------------------------------------------------------------------------------------------
local policy_text = table.concat({
	"# who: commands",
	"Alice: *",
	BOB .. ": where goto",
	"Carol : say  timeout",
	"",
	"bogus line without colon",
}, "\n")
local policy, errors = gm.parse_policy(policy_text)
eq("one error for the bad line", #errors, 1)
if errors[1] and not errors[1]:find("line 6", 1, true) then fail("error does not name the line: " .. errors[1]) end

-- Authorization as a classifier: every sender x command, allow/deny. Senders by name, by FLS id, unlisted,
-- and unresolvable (whois failed: no name).
local COMMANDS = { "help", "where", "goto", "bring", "say", "timeout", "give", "kick", "bogus" }
local senders = {
	{ "alice by name", ALICE, "Alice", { help = 1, where = 1, goto = 1, bring = 1, say = 1, timeout = 1, give = 1, kick = 1 } },
	{ "bob by fls", BOB, "Bob", { help = 1, where = 1, goto = 1 } },
	{ "bob unresolved", BOB, nil, { help = 1, where = 1, goto = 1 } },
	{ "carol spaced", CAROL, "Carol", { help = 1, say = 1, timeout = 1 } },
	{ "dave unlisted", DAVE, "Dave", {} },
	{ "alice's name on another account", DAVE, "alice", {} },
	{ "unresolved unlisted", DAVE, nil, {} },
	-- An entry that is an FLS id matches that account only, never a character named like it.
	{ "character named like bob's id", DAVE, BOB, {} },
}
local got, want = {}, {}
for _, s in ipairs(senders) do
	for _, cmd in ipairs(COMMANDS) do
		got[#got + 1] = s[1] .. " " .. cmd .. "=" .. tostring(gm.authorize(policy, s[2], s[3], cmd))
		want[#want + 1] = s[1] .. " " .. cmd .. "=" .. tostring(s[4][cmd] == 1)
	end
end
for i = 1, #want do eq("authorize " .. want[i], got[i], want[i]) end
-- Fail closed: no policy (missing file), empty, comments only, or only bad lines.
for _, text in ipairs({ false, "", "# nobody\n", "Alice *\n" }) do
	local p = gm.parse_policy(text or nil)
	for _, cmd in ipairs(COMMANDS) do
		if gm.authorize(p, ALICE, "Alice", cmd) then fail("policy " .. tostring(text) .. " allowed " .. cmd) end
	end
end

-- Plans: argv for dune-live and the reply -----------------------------------------------------------------------
local alice = { fls = ALICE, name = "Alice", origin = { x = 155566.13, y = 300580.16, z = 1590.89 } }
local function plan(text) return gm.plan(gm.parse_command(text), alice, policy) end
local p = plan("&where")
same("where: no actions", p.actions, {}); eq("where reply", p.reply, "you are at X 155566 Y 300580 Z 1591")
p = plan("&goto Bob")
same("goto", p.actions, { { "character", "move", "Alice", "to", "Bob" } })
p = plan("&bring Bob")
same("bring", p.actions, { { "character", "move", "Bob", "to", "Alice" } })
p = plan("&say Restart in 5 minutes; $(reboot) `x` 'q'")
same("say keeps text verbatim as one argument", p.actions, { { "world", "say", "Restart in 5 minutes; $(reboot) `x` 'q'" } })
same("timeout on", plan("&timeout on").actions, { { "world", "timeout", "on" } })
same("timeout status", plan("&timeout").actions, { { "world", "timeout", "status" } })
same("give", plan("&give SandbikeChassis_1 2").actions, { { "character", "give", "Alice", "SandbikeChassis_1", "2" } })
same("give default count", plan("&give Ammo").actions, { { "character", "give", "Alice", "Ammo", "1" } })
same("kick", plan("&kick Bob").actions, { { "character", "kick", "Bob" } })
same("player names with spaces", plan("&goto Bob Two").actions, { { "character", "move", "Alice", "to", "Bob Two" } })
-- Usage errors produce no actions and a short reply.
for _, bad in ipairs({ "&goto", "&goto Alice", "&bring", "&say", "&timeout maybe", "&give", "&give Bad;Item", "&give Ammo 0",
	"&give Ammo 1001", "&give Ammo x", "&kick", "&goto --help", "&say -h", "&kick -x", "&bogus" }) do
	p = plan(bad)
	if #p.actions ~= 0 then fail(bad .. " produced actions: " .. cjson.encode(p.actions)) end
	if not (p.reply and #p.reply > 0) then fail(bad .. " has no reply") end
end
p = gm.plan(gm.parse_command("&where"), { fls = ALICE, name = "Alice" }, policy)
eq("where without origin: no actions", #p.actions, 0); eq("where without origin: reply", p.reply, "your position is unknown")
-- help lists only what the sender may run.
eq("help for alice", plan("&help").reply, "commands: bring, give, goto, kick, say, timeout, where")
eq("help for bob", gm.plan(gm.parse_command("&help"), { fls = BOB, name = "Bob" }, policy).reply, "commands: goto, where")
eq("not allowed reply", gm.NOT_ALLOWED, "not allowed")
eq("log line flattens control characters", gm.log_line(ALICE, "Alice", "&say a\nb", "allowed"), "0123456789ABCDEF Alice allowed: &say a b")
eq("log line without a name", gm.log_line(DAVE, nil, "&kick x", "denied"), "00000000000000BB ? denied: &kick x")

-- Shell quoting for the argv the bridge runs: bash must hand back every string byte for byte.
do
	local nasty = { "plain", "", "it's", "$(touch /nonexistent)", "`id`", "a b\tc", "\"q\"", "back\\slash", "*", "-h", "'", "''\n'" }
	local parts = {}
	for i, s in ipairs(nasty) do parts[i] = gm.shell_quote(s) end
	local p = io.popen("bash --norc --noprofile -c 'for a in \"$@\"; do printf \"%s\\0\" \"$a\"; done' _ " .. table.concat(parts, " "))
	local out = p:read("*a"); p:close()
	local got = {}
	for s in out:gmatch("([^%z]*)%z") do got[#got + 1] = s end
	same("shell_quote round trip", got, nasty)
	eq("argv to a command line", gm.command_line({ "/x/dune-live", "world", "say", "a'b" }), "'/x/dune-live' 'world' 'say' 'a'\\''b'")
end

os.exit(failures == 0 and 0 or 1)
