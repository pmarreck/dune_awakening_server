-- Unit tests for libexec/lib/gm_bridge.lua (run by tests/unit/gm-bridge). Names and ids are synthetic.
package.path = "libexec/lib/?.lua;" .. package.path
local gm = require("gm_bridge")
local items = require("items")
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
	"Erin: give",
	"Frank: give-others",
	"",
	"bogus line without colon",
}, "\n")
local policy, errors = gm.parse_policy(policy_text)
eq("one error for the bad line", #errors, 1)
if errors[1] and not errors[1]:find("line 8", 1, true) then fail("error does not name the line: " .. errors[1]) end

-- Authorization as a classifier: every sender x command, allow/deny. Senders by name, by FLS id, unlisted,
-- and unresolvable (whois failed: no name).
local COMMANDS = { "help", "where", "goto", "bring", "say", "timeout", "give", "give-others", "kick", "bogus" }
local senders = {
	{ "alice by name", ALICE, "Alice", { help = 1, where = 1, goto = 1, bring = 1, say = 1, timeout = 1, give = 1, ["give-others"] = 1, kick = 1 } },
	{ "bob by fls", BOB, "Bob", { help = 1, where = 1, goto = 1 } },
	{ "bob unresolved", BOB, nil, { help = 1, where = 1, goto = 1 } },
	{ "carol spaced", CAROL, "Carol", { help = 1, say = 1, timeout = 1 } },
	{ "dave unlisted", DAVE, "Dave", {} },
	{ "alice's name on another account", DAVE, "alice", {} },
	{ "unresolved unlisted", DAVE, nil, {} },
	{ "erin gives to herself only", "00000000000000EE", "Erin", { help = 1, give = 1 } },
	{ "frank gives to others only", "00000000000000FF", "Frank", { help = 1, ["give-others"] = 1 } },
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
-- Item names: the curated list shipped in the repo plus a tiny synthetic generated list.
local f = assert(io.open("data/items.tsv", "rb")); local curated = items.parse_curated(f:read("*a")); f:close()
local generated = items.parse_generated(table.concat({ "FremenComponent1\tEMF Generator\t0", "D_FremenComponent3\tEMF Generator\t1",
	"SolarisCoin\tSolari\t0", "SandbikeChassis_1\tSandbike Chassis\t0", "Ammo\tLight Darts\t0", "BarA\tTwin Bar\t0", "BarB\tTwin Bar\t0" }, "\n"))
local db, nogen = items.build(curated, generated), items.build(curated, nil)
local function plan(text, d) return gm.plan(gm.parse_command(text), alice, policy, d == nil and db or d) end
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
same("give by id", plan("&give SandbikeChassis_1 2").actions, { { "character", "give", "Alice", "SandbikeChassis_1", "2" } })
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
eq("help for alice", plan("&help").reply, "commands: bring, give, give-others, goto, kick, say, timeout, where")
eq("help for bob", gm.plan(gm.parse_command("&help"), { fls = BOB, name = "Bob" }, policy).reply, "commands: goto, where")
eq("not allowed reply", gm.NOT_ALLOWED, "not allowed")

-- &give <item name or id> [count] [to <player>] ------------------------------------------------------------------
-- The permission a command needs: give to yourself is give; to anyone else, give-others. A classifier over a set.
for _, c in ipairs({
	{ "&give solari", "give" }, { "&give solari 5000", "give" }, { "&give emf generator 2 to Bob", "give-others" },
	{ "&give solari to Alice", "give" }, { "&give solari TO bob two", "give-others" }, { "&give ticket to ride to Alice", "give" },
	{ "&give", "give" }, { "&give solari to", "give" }, { "&where", "where" }, { "&goto Bob", "goto" }, { "&help", "help" },
}) do
	eq("permission " .. c[1], gm.permission(gm.parse_command(c[1]), "Alice"), c[2])
end

local FULL = "; a full inventory can drop items"
local give_cases = {
	{ "&give emf generator 2 to Bob", { { "character", "give", "Bob", "FremenComponent1", "2" } }, "gave Bob 2 EMF Generator (FremenComponent1)" .. FULL },
	{ "&give  EMF   generator  TO  Bob Two", { { "character", "give", "Bob Two", "FremenComponent1", "1" } }, "gave Bob Two 1 EMF Generator (FremenComponent1)" .. FULL },
	{ "&give solari 5000", { { "character", "give", "Alice", "SolarisCoin", "5000" } }, "gave you 5000 Solari (SolarisCoin)" .. FULL },
	{ "&give money 1000000", { { "character", "give", "Alice", "SolarisCoin", "1000000" } }, "gave you 1000000 Solari (SolarisCoin)" .. FULL },
	{ "&give HarkAr2", { { "character", "give", "Alice", "HarkAr2", "1" } }, "gave you 1 Karpov 38 rifle (HarkAr2)" .. FULL },
	-- A name ending in a number: the whole text names an item, so the number is part of the name, not a count.
	{ "&give karpov 38", { { "character", "give", "Alice", "HarkAr2", "1" } }, "gave you 1 Karpov 38 rifle (HarkAr2)" .. FULL },
	{ "&give Karpov-38 to Bob", { { "character", "give", "Bob", "HarkAr2", "1" } }, "gave Bob 1 Karpov 38 rifle (HarkAr2)" .. FULL },
	{ "&give karpov 38 2", { { "character", "give", "Alice", "HarkAr2", "2" } }, "gave you 2 Karpov 38 rifle (HarkAr2)" .. FULL },
	{ "&give karpov 3", { { "character", "give", "Alice", "HarkAr2", "3" } }, "gave you 3 Karpov 38 rifle (HarkAr2)" .. FULL },
	{ "&give solari 3 to Alice", { { "character", "give", "Alice", "SolarisCoin", "3" } }, "gave you 3 Solari (SolarisCoin)" .. FULL },
	{ "&give D_FremenComponent3", { { "character", "give", "Alice", "D_FremenComponent3", "1" } }, "gave you 1 EMF Generator (D_FremenComponent3)" .. FULL },
	{ "&give raider tokens 10", { { "character", "give", "Alice", "EventRaiderToken", "10" } }, "gave you 10 Raider Tokens (EventRaiderToken, id not yet verified in game)" .. FULL },
	{ "&give solari 1000001 to Bob", {}, "at most 1000000 Solari (SolarisCoin) per give" },
	{ "&give emf 1001", {}, "at most 1000 EMF Generator (FremenComponent1) per give" },
	{ "&give twin bar", {}, 'several items are named "twin bar": Twin Bar (BarA), Twin Bar (BarB); give one by id' },
	{ "&give solary 5", {}, 'no item "solary"; did you mean: Solari (SolarisCoin)?' },
	{ "&give zzqqzzqq", {}, 'no item "zzqqzzqq"; try another name or an item id' },
	{ "&give FooBar_9 2", {}, 'no item "FooBar_9"; try another name or an item id' },
	{ "&give FooBar_9 2", { { "character", "give", "Alice", "FooBar_9", "2" } }, "gave you 2 FooBar_9 (not in the item list; nothing arrives if the game does not know it)" .. FULL, nogen },
}
for _, c in ipairs(give_cases) do
	p = plan(c[1], c[4])
	same(c[1] .. " actions", p.actions, c[2]); eq(c[1] .. " reply", p.reply, c[3])
end
-- Suggestions stop at five, and say how many more there were.
local many = {}
for i = 1, 8 do many[i] = "Rock" .. i .. "\tRock Type " .. i .. "\t0" end
p = plan("&give rock type", items.build({}, items.parse_generated(table.concat(many, "\n"))))
eq("suggestions capped", p.reply, 'no item "rock type"; did you mean: Rock Type 1 (Rock1), Rock Type 2 (Rock2), Rock Type 3 (Rock3), Rock Type 4 (Rock4), Rock Type 5 (Rock5), and 3 more?')
for _, bad in ipairs({ "&give", "&give 5", "&give to Bob", "&give solari to", "&give solari 0", "&give solari 5 to -h", "&give solari to Bob\tx" }) do
	p = plan(bad)
	if #p.actions ~= 0 then fail(bad .. " produced actions: " .. cjson.encode(p.actions)) end
	eq(bad .. " usage", p.reply, "usage: &give <item name or id> [count] [to <player>]")
end
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
