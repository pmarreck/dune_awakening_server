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
	"Gina: water",
	"",
	"bogus line without colon",
}, "\n")
local policy, errors = gm.parse_policy(policy_text)
eq("one error for the bad line", #errors, 1)
if errors[1] and not errors[1]:find("line 9", 1, true) then fail("error does not name the line: " .. errors[1]) end

-- Authorization as a classifier: every sender x command, allow/deny. Senders by name, by FLS id, unlisted,
-- and unresolvable (whois failed: no name).
local COMMANDS = { "help", "where", "goto", "bring", "say", "timeout", "give", "give-others", "fuel", "fuel-others", "kick", "newbie", "thufir", "time", "unlock", "unlock-others", "water", "water-others", "bogus" }
local senders = {
	{ "alice by name", ALICE, "Alice", { help = 1, where = 1, goto = 1, bring = 1, say = 1, timeout = 1, give = 1, ["give-others"] = 1, fuel = 1, ["fuel-others"] = 1, kick = 1, newbie = 1, thufir = 1, time = 1, unlock = 1, ["unlock-others"] = 1, water = 1, ["water-others"] = 1 } },
	{ "bob by fls", BOB, "Bob", { help = 1, where = 1, goto = 1 } },
	{ "bob unresolved", BOB, nil, { help = 1, where = 1, goto = 1 } },
	{ "carol spaced", CAROL, "Carol", { help = 1, say = 1, timeout = 1 } },
	{ "dave unlisted", DAVE, "Dave", {} },
	{ "alice's name on another account", DAVE, "alice", {} },
	{ "unresolved unlisted", DAVE, nil, {} },
	{ "erin gives to herself only", "00000000000000EE", "Erin", { help = 1, give = 1 } },
	{ "frank gives to others only", "00000000000000FF", "Frank", { help = 1, ["give-others"] = 1 } },
	{ "gina waters herself only", "0000000000000099", "Gina", { help = 1, water = 1 } },
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
-- Item names: the curated list shipped in the repo plus a tiny synthetic generated list (id, name, deprecated,
-- category, stack size).
local f = assert(io.open("data/items.tsv", "rb")); local curated = items.parse_curated(f:read("*a")); f:close()
local generated = items.parse_generated(table.concat({ "FremenComponent1\tEMF Generator\t0\tResources\t500",
	"D_FremenComponent3\tEMF Generator\t1\tResources\t500", "SolarisCoin\tSolari\t0\tResources\t50000",
	"SandbikeChassis_1\tSandbike Chassis\t0\tVehicles\t1", "Ammo\tLight Darts\t0\tWeapons\t1000", "HarkAr2\tKarpov 38\t0\tWeapons\t1",
	"BarA\tTwin Bar\t0", "BarB\tTwin Bar\t0" }, "\n"))
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
same("water refills your own containers", plan("&water").actions, { { "character", "water", "Alice", gm.WATER_FILL } })
same("water for another player", plan("&water Bob Two").actions, { { "character", "water", "Bob Two", gm.WATER_FILL } })
eq("water permission for yourself", gm.permission(gm.parse_command("&water"), "Alice"), "water")
eq("water naming yourself is still water", gm.permission(gm.parse_command("&water Alice"), "Alice"), "water")
eq("water for another needs water-others", gm.permission(gm.parse_command("&water Bob"), "Alice"), "water-others")
-- &fuel: large vehicle fuel cells (the game's vehicle "battery") into the inventory. No server command fills a
-- vehicle's tank directly, so the reply says to load one.
same("fuel gives large fuel cells", plan("&fuel").actions, { { "character", "give", "Alice", "FuelCanister_Large", gm.FUEL_COUNT } })
same("fuel for another player", plan("&fuel Bob Two").actions, { { "character", "give", "Bob Two", "FuelCanister_Large", gm.FUEL_COUNT } })
if not plan("&fuel").reply:find("fuel cell", 1, true) then fail("fuel reply does not name the item: " .. plan("&fuel").reply) end
eq("fuel permission for yourself", gm.permission(gm.parse_command("&fuel"), "Alice"), "fuel")
eq("fuel naming yourself is still fuel", gm.permission(gm.parse_command("&fuel Alice"), "Alice"), "fuel")
eq("fuel for another needs fuel-others", gm.permission(gm.parse_command("&fuel Bob"), "Alice"), "fuel-others")
-- &unlock <school> [to <player>]: dune-live normalizes the school name, so the bridge passes the words through.
same("unlock for yourself", plan("&unlock Bene Gesserit").actions, { { "character", "unlock-tree", "Alice", "Bene Gesserit" } })
same("unlock for another", plan("&unlock sword to Bob Two").actions, { { "character", "unlock-tree", "Bob Two", "sword" } })
eq("unlock permission", gm.permission(gm.parse_command("&unlock bg"), "Alice"), "unlock")
eq("unlock naming yourself", gm.permission(gm.parse_command("&unlock bg to Alice"), "Alice"), "unlock")
eq("unlock for another needs unlock-others", gm.permission(gm.parse_command("&unlock bg to Bob"), "Alice"), "unlock-others")
-- The player may follow the school directly or after `to`/`for`; the longest known school name at the start wins.
for _, c in ipairs({
	{ "&unlock bene gesserit for Bob Two", "Bob Two", "bene gesserit" }, { "&unlock bene gesserit Bob Two", "Bob Two", "bene gesserit" },
	{ "&unlock BG Bob", "Bob", "BG" }, { "&unlock swordmaster to Bob", "Bob", "swordmaster" }, { "&unlock sword Bob", "Bob", "sword" },
	{ "&unlock Trooper", "Alice", "Trooper" }, { "&unlock Bene  Gesserit", "Alice", "Bene  Gesserit" },
	{ "&UNLOCK BENE GESSERIT FOR Bob Two", "Bob Two", "BENE GESSERIT" }, { "&Unlock Swordmaster TO Bob", "Bob", "Swordmaster" }, { "&unlock bG bob", "bob", "bG" },
}) do same("unlock: " .. c[1], plan(c[1]).actions, { { "character", "unlock-tree", c[2], c[3] } }) end
eq("unlock <school> <player> needs unlock-others", gm.permission(gm.parse_command("&unlock mentat Bob"), "Alice"), "unlock-others")
eq("unlock for yourself by name", gm.permission(gm.parse_command("&unlock mentat for Alice"), "Alice"), "unlock")
for _, bad in ipairs({ "&unlock sardaukar", "&unlock sardaukar Bob", "&unlock for Bob", "&unlock bg for" }) do
	p = plan(bad); if #p.actions ~= 0 then fail(bad .. " produced actions") end
end
-- &thufir <message>: no dune-live action; a note for the operator's assistant, delivered by the bridge.
p = plan("&thufir Where is Sister Mesa?  $(x) | y")
same("thufir has no dune-live actions", p.actions, {})
same("thufir carries the note verbatim", p.note, { from = "Alice", text = "Where is Sister Mesa?  $(x) | y" })
eq("thufir reply", p.reply, "sent to Thufir")
eq("thufir permission", gm.permission(gm.parse_command("&thufir hi"), "Alice"), "thufir")
-- The note file: llmsend/v1 JSON frontmatter, a safe filename, the message as the body.
local nf = gm.thufir_note({ from = "Mahdi by Nature", text = "line one\nlinе \"two\"" }, "2026-10-05T00:01:02-04:00", "a1b2")
eq("note filename", nf.name, "2026-10-05-from-game-mahdi-by-nature-a1b2.frontmatter.md")
local fm = nf.text:match("^%-%-%-json\n(.-)\n%-%-%-\n")
local meta = fm and cjson.decode(fm)
if not meta then fail("note frontmatter is not ---json ... --- JSON: " .. nf.text) else
	eq("note schema", meta.schema, "llmsend/v1"); eq("note sender", meta.sender, "Mahdi by Nature (in game)")
	eq("note recipient", meta.recipient, "dune_awakening_server"); eq("note type", meta.message_type, "question")
	eq("note datetime", meta.datetime, "2026-10-05T00:01:02-04:00"); eq("note reply expected", meta.response_expected, true)
	eq("note reply hint", meta.description:find("whisper", 1, true) ~= nil, true)
end
if not nf.text:find('line one\nlinе "two"', 1, true) then fail("note body lost the message: " .. nf.text) end
eq("filename of an odd name stays safe", gm.thufir_note({ from = "../x/../ Y!", text = "t" }, "2026-10-05T00:00:00-04:00", "ff").name, "2026-10-05-from-game-x-y-ff.frontmatter.md")
if not (type(gm.WATER_FILL) == "string" and tonumber(gm.WATER_FILL) and tonumber(gm.WATER_FILL) > 0) then fail("WATER_FILL must be a positive amount string") end
same("player names with spaces", plan("&goto Bob Two").actions, { { "character", "move", "Alice", "to", "Bob Two" } })
-- Usage errors produce no actions and a short reply.
for _, bad in ipairs({ "&goto", "&goto Alice", "&bring", "&say", "&timeout maybe", "&give", "&give Bad;Item", "&give Ammo 0",
	"&give Ammo 1001", "&give Ammo x", "&kick", "&goto --help", "&say -h", "&kick -x", "&water -x", "&fuel -x", "&thufir", "&unlock", "&unlock to Bob", "&unlock -x", "&bogus" }) do
	p = plan(bad)
	if #p.actions ~= 0 then fail(bad .. " produced actions: " .. cjson.encode(p.actions)) end
	if not (p.reply and #p.reply > 0) then fail(bad .. " has no reply") end
end
p = gm.plan(gm.parse_command("&where"), { fls = ALICE, name = "Alice" }, policy)
eq("where without origin: no actions", #p.actions, 0); eq("where without origin: reply", p.reply, "your position is unknown")
-- help lists only what the sender may run.
eq("help for alice", plan("&help").reply, "commands: bring, fuel, fuel-others, give, give-others, goto, kick, newbie, say, thufir, time, timeout, unlock, unlock-others, water, water-others, where")
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
	{ "&give HarkAr2", { { "character", "give", "Alice", "HarkAr2", "1" } }, "gave you 1 Karpov-38 (HarkAr2)" .. FULL },
	-- A standalone trailing number is always the count: names containing numbers are typed
	-- hyphenated (karpov-38), and replies show them that way. Matching ignores spacing and punctuation.
	{ "&give karpov 38", {}, "at most 10 Karpov-38 (HarkAr2) per give" },
	{ "&give karpov-38 10", { { "character", "give", "Alice", "HarkAr2", "10" } }, "gave you 10 Karpov-38 (HarkAr2)" .. FULL },
	{ "&give karpov-38", { { "character", "give", "Alice", "HarkAr2", "1" } }, "gave you 1 Karpov-38 (HarkAr2)" .. FULL },
	{ "&give Karpov-38 to Bob", { { "character", "give", "Bob", "HarkAr2", "1" } }, "gave Bob 1 Karpov-38 (HarkAr2)" .. FULL },
	{ "&give karpov-38 2", { { "character", "give", "Alice", "HarkAr2", "2" } }, "gave you 2 Karpov-38 (HarkAr2)" .. FULL },
	{ "&give karpov 3", { { "character", "give", "Alice", "HarkAr2", "3" } }, "gave you 3 Karpov-38 (HarkAr2)" .. FULL },
	{ "&give solari 3 to Alice", { { "character", "give", "Alice", "SolarisCoin", "3" } }, "gave you 3 Solari (SolarisCoin)" .. FULL },
	{ "&give D_FremenComponent3", { { "character", "give", "Alice", "D_FremenComponent3", "1" } }, "gave you 1 EMF Generator (D_FremenComponent3)" .. FULL },
	{ "&give raider tokens 10", { { "character", "give", "Alice", "EventRaiderToken", "10" } }, "gave you 10 Raider Tokens (EventRaiderToken, id not yet verified in game)" .. FULL },
	{ "&give solari 1000001 to Bob", {}, "at most 1000000 Solari (SolarisCoin) per give" },
	-- Without a curated max count, the cap is the item's stack size (at least 10), else 1000.
	{ "&give emf 500", { { "character", "give", "Alice", "FremenComponent1", "500" } }, "gave you 500 EMF Generator (FremenComponent1)" .. FULL },
	{ "&give emf 501", {}, "at most 500 EMF Generator (FremenComponent1) per give" },
	{ "&give light darts 1001", {}, "at most 1000 Light Darts (Ammo) per give" },
	{ "&give sandbike chassis 11", {}, "at most 10 Sandbike Chassis (SandbikeChassis_1) per give" },
	{ "&give twin bar", {}, 'several items are named "twin bar": Twin Bar (BarA), Twin Bar (BarB); give one by id' },
	{ "&give BarA 1000", { { "character", "give", "Alice", "BarA", "1000" } }, "gave you 1000 Twin Bar (BarA)" .. FULL },
	{ "&give BarA 1001", {}, "at most 1000 Twin Bar (BarA) per give" },
	{ "&give FooBar_9 1001", {}, "at most 1000 FooBar_9 (FooBar_9) per give", nogen },
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
eq("suggestions capped", p.reply, 'no item "rock type"; did you mean: Rock Type-1 (Rock1), Rock Type-2 (Rock2), Rock Type-3 (Rock3), Rock Type-4 (Rock4), Rock Type-5 (Rock5), and 3 more?')
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

-- &newbie: a random newcomer tip, optionally from one category. Tips come from a TSV (category<TAB>text); the
-- choice is injected (pick(n) -> 1..n) so tests are deterministic.
do
	local tips = gm.parse_tips("# comment\nworms\tStay on rock.\n\nwater\tDrink early.\nWorms\tCross in hops.\nbroken line without tab\n")
	same("parse_tips keeps category/text rows only", tips, {
		{ category = "worms", text = "Stay on rock." }, { category = "water", text = "Drink early." }, { category = "worms", text = "Cross in hops." } })
	local seen
	local function pick(n) seen = n; return n end
	local function nb(text) return gm.plan(gm.parse_command(text), alice, policy, nil, tips, pick) end
	local r = nb("&newbie")
	same("newbie: no actions", r.actions, {})
	eq("newbie: random over all tips", seen, 3); eq("newbie reply", r.reply, "tip (worms): Cross in hops.")
	r = nb("&newbie WATER")
	eq("newbie category, any case", r.reply, "tip (water): Drink early."); eq("newbie category pool", seen, 1)
	r = nb("&newbie worms"); eq("newbie category pool of two", seen, 2); eq("newbie worms reply", r.reply, "tip (worms): Cross in hops.")
	eq("newbie unknown category lists categories", nb("&newbie lasguns").reply, "no tips about lasguns; try: water, worms")
	eq("newbie with no tips loaded", gm.plan(gm.parse_command("&newbie"), alice, policy, nil, {}, pick).reply, "no tips available")
	eq("newbie permission", gm.permission(gm.parse_command("&newbie worms"), "Alice"), "newbie")
end

-- &time: the game does not report a player's time zone, so the operator assigns one per player (tz= on the policy
-- line); without one the reply uses the server's zone and says so. The plan only names the zone; the bridge formats.
do
	local p, errs = gm.parse_policy(table.concat({ "Alice: * tz=America/New_York", BOB .. ": time tz=America/Los_Angeles",
		"Carol: time", "Erin: time tz=", "Frank: time tz=../../etc/passwd", "Gina: time tz=America/New_York tz=UTC" }, "\n"))
	eq("tz errors: empty, path, repeated", #errs, 3)
	eq("empty tz names its line", (errs[1] or ""):find("line 4", 1, true) ~= nil, true)
	eq("path-like tz rejected", (errs[2] or ""):find("line 5", 1, true) ~= nil, true)
	eq("repeated tz rejected", (errs[3] or ""):find("line 6", 1, true) ~= nil, true)
	eq("tz does not grant a command", gm.authorize(p, ALICE, "Alice", "time"), true)
	eq("tz=... is not a command name", gm.authorize(p, "00000000000000EE", "Erin", "time"), true)
	eq("zone by name", gm.timezone(p, ALICE, "Alice"), "America/New_York")
	eq("zone by fls", gm.timezone(p, BOB, "Bob"), "America/Los_Angeles")
	eq("no zone set", gm.timezone(p, CAROL, "Carol"), nil)
	eq("unlisted sender has no zone", gm.timezone(p, DAVE, "Dave"), nil)
	local t = gm.plan(gm.parse_command("&time"), alice, p)
	same("time: no actions", t.actions, {})
	same("time: zone to format", t.clock, { tz = "America/New_York" })
	eq("time with an argument is a usage error", gm.plan(gm.parse_command("&time now"), alice, p).reply, "usage: &time")
	same("time without a zone", gm.plan(gm.parse_command("&time"), { fls = CAROL, name = "Carol" }, p).clock, { tz = false })
	eq("reply with a zone", gm.time_reply("12:20 AM EDT, Tue Oct 27", "America/New_York"),
		"it is 12:20 AM EDT, Tue Oct 27 (America/New_York, set for you in gm_bridge.conf)")
	eq("reply without a zone", gm.time_reply("4:20 AM UTC, Tue Oct 27", false),
		"it is 4:20 AM UTC, Tue Oct 27 (the server's time zone; the operator can set yours in gm_bridge.conf)")
end

-- Repeats: the game hands the bridge one copy of a chat line per online player, so a line identical to one the same
-- sender sent within REPEAT_WINDOW seconds is a copy and runs once. A classifier over sender, text and age.
do
	eq("repeat window", gm.REPEAT_WINDOW, 3)
	local cases = {
		-- { label, earlier {fls, text, t} or nil, now {fls, text, t}, want repeat }
		{ "first line", nil, { ALICE, "&time", 100 }, false },
		{ "copy one second later", { ALICE, "&time", 100 }, { ALICE, "&time", 101 }, true },
		{ "copy in the same second", { ALICE, "&time", 100 }, { ALICE, "&time", 100 }, true },
		{ "copy at the window's edge", { ALICE, "&time", 100 }, { ALICE, "&time", 103 }, true },
		{ "same line after the window", { ALICE, "&time", 100 }, { ALICE, "&time", 104 }, false },
		{ "other text", { ALICE, "&time", 100 }, { ALICE, "&where", 101 }, false },
		{ "other sender, same text", { ALICE, "&time", 100 }, { BOB, "&time", 101 }, false },
		{ "case differs", { ALICE, "&give solari 5", 100 }, { ALICE, "&give Solari 5", 101 }, false },
	}
	for _, c in ipairs(cases) do
		local recent = {}
		if c[2] then local _; _, recent = gm.is_repeat(recent, c[2][1], c[2][2], c[2][3], "rk.first") end
		local rep, _, first = gm.is_repeat(recent, c[3][1], c[3][2], c[3][3], "rk.second")
		eq("repeat: " .. c[1], rep, c[4])
		if c[4] then eq("repeat names the first copy's routing key: " .. c[1], first, "rk.first") end
	end
	-- A third copy (three players online) is still a repeat of the first; the window runs from the first copy.
	local r = {}
	local _; _, r = gm.is_repeat(r, ALICE, "&time", 100, "a")
	local rep2; rep2, r = gm.is_repeat(r, ALICE, "&time", 101, "b")
	local rep3; rep3, r = gm.is_repeat(r, ALICE, "&time", 102, "c")
	eq("third copy is a repeat", rep3, true)
	eq("a line repeated every second for long is not held back forever", (gm.is_repeat(r, ALICE, "&time", 104, "d")), false)
	-- Entries older than the window are pruned, so the table stays small.
	local big = {}
	for i = 1, 50 do _, big = gm.is_repeat(big, ALICE, "&say " .. i, i, "k") end
	local n = 0; for _ in pairs(big) do n = n + 1 end
	eq("old entries pruned", n <= gm.REPEAT_WINDOW + 1, true)
end

os.exit(failures == 0 and 0 or 1)
