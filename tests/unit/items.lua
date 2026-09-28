-- Unit tests for libexec/lib/items.lua (run by tests/unit/items): curated and generated item lists merged into one
-- name lookup, curated winning. The generated text here is a small synthetic stand-in, not the game's tables.
package.path = "libexec/lib/?.lua;" .. package.path
local items = require("items")
local failures = 0
local function fail(msg) io.stderr:write("FAIL ", msg, "\n"); failures = failures + 1 end
local function eq(name, got, want)
	if got ~= want then fail(string.format("%s: got %s, want %s", name, tostring(got), tostring(want))) end
end
local T = "\t"
local function tsv(rows) local out = {}; for i, r in ipairs(rows) do out[i] = table.concat(r, T) end; return table.concat(out, "\n") .. "\n" end

-- Normalization: case, spacing and punctuation do not matter; apostrophes vanish.
for _, c in ipairs({ { "  EMF   Generator ", "emf generator" }, { "Karpov-38", "karpov 38" }, { "Flamegouger's Jacket", "flamegougers jacket" },
	{ "a\tb\nc", "a b c" }, { "", "" } }) do
	eq("normalize " .. c[1], items.normalize(c[1]), c[2])
end

-- Curated: id, verified, max count (- = default), aliases. Bad lines are reported, not fatal.
local curated_text = "# id\tverified\tmax\taliases\n" .. tsv({
	{ "FremenComponent1", "yes", "-", "EMF Generator|emf" },
	{ "SolarisCoin", "yes", "1000000", "Solari|money|cash" },
	{ "HouseCredit", "no", "-", "House Credits" },
	{ "HarkAr2", "yes", "-", "Karpov 38 rifle|karpov 38" },
}) .. "bad line\nAlso\tmaybe\t-\tx\nNeg\tyes\t0\tneg\nNoAlias\tyes\t-\t\n"
local curated, errors = items.parse_curated(curated_text)
eq("curated entries", #curated, 4)
eq("curated errors", #errors, 4)
for i, want in ipairs({ "line 6", "line 7", "line 8", "line 9" }) do
	if not (errors[i] or ""):find(want, 1, true) then fail("curated error " .. i .. " does not name " .. want .. ": " .. tostring(errors[i])) end
end

-- Generated: id, display name, deprecated flag. A deprecated item that shares a live item's name is never chosen by
-- that name; two live items sharing a name are ambiguous.
local generated = items.parse_generated("# generated\n" .. tsv({
	{ "FremenComponent1", "EMF Generator", "0" },
	{ "D_FremenComponent3", "EMF Generator", "1" },
	{ "SolarisCoin", "Solari", "0" },
	{ "OldThing", "Old Thing", "1" },
	{ "BarA", "Twin Bar", "0" },
	{ "BarB", "Twin Bar", "0" },
	{ "GlowStick_1", "Glow Stick", "0" },
	{ "GlowStickDep", "Glow Stick", "1" },
	{ "HarkAr3", "Karpov 38", "0" },
	{ "ScrapKnife", "Scrap Metal Knife", "0" },
	{ "ScrapAxe", "Scrap Metal Axe", "0" },
}))
eq("generated entries", #generated, 11)

local db = items.build(curated, generated)
local nogen = items.build(curated, nil)
local function outcome(d, q)
	local r = items.resolve(d, q)
	if r.item then return (r.item.raw and "raw:" or "item:") .. r.item.id end
	local ids = {}
	for i, c in ipairs(r.candidates or {}) do ids[i] = c.id end
	return (r.ambiguous and "ambiguous:" or "unknown:") .. table.concat(ids, ",")
end
-- Classifier over a set of queries: each maps to exactly one outcome.
local cases = {
	{ db, "emf generator", "item:FremenComponent1" },   -- the trap: curated wins, D_FremenComponent3 never chosen by name
	{ db, "EMF   GENERATOR", "item:FremenComponent1" },
	{ db, "emf", "item:FremenComponent1" },             -- alias
	{ db, "D_FremenComponent3", "item:D_FremenComponent3" }, -- a raw id still works
	{ db, "d_fremencomponent3", "item:D_FremenComponent3" }, -- id case-insensitive
	{ db, "solari", "item:SolarisCoin" },
	{ db, "Money", "item:SolarisCoin" },
	{ db, "SolarisCoin", "item:SolarisCoin" },
	{ db, "house credits", "item:HouseCredit" },         -- curated only (not in the generated list)
	{ db, "karpov 38", "item:HarkAr2" },                 -- curated alias beats a generated item with that name
	{ db, "Karpov-38", "item:HarkAr2" },
	{ db, "old thing", "item:OldThing" },                -- deprecated but the only one with the name
	{ db, "glow stick", "item:GlowStick_1" },            -- live beats deprecated
	{ db, "twin bar", "ambiguous:BarA,BarB" },
	{ db, "scrap metal", "unknown:ScrapAxe,ScrapKnife" }, -- partial name: suggestions, never a give
	{ db, "solary", "unknown:SolarisCoin" },             -- typo: nearest name
	{ db, "Glowstick", "unknown:GlowStick_1" },
	{ db, "zzzzqqqq", "unknown:" },
	{ db, "NotAnItem", "unknown:" },                     -- with a generated list, an unknown id is not passed through
	{ nogen, "NotAnItem", "raw:NotAnItem" },             -- without one, a single id-shaped word is (the server checks it)
	{ nogen, "not an item", "unknown:" },
	{ nogen, "emf generator", "item:FremenComponent1" },
}
for _, c in ipairs(cases) do eq("resolve " .. c[2] .. (c[1] == nogen and " (no generated list)" or ""), outcome(c[1], c[2]), c[3]) end
-- The curated list alone keeps the EMF trap shut, even if the other EMF Generator were not marked deprecated.
eq("curated wins over a live namesake", outcome(items.build(curated, items.parse_generated(tsv({ { "FremenComponent1", "EMF Generator", "0" },
	{ "D_FremenComponent3", "EMF Generator", "0" } }))), "emf generator"), "item:FremenComponent1")

-- What a resolved item carries: friendly name (generated display name, else the first alias), cap, verified.
local r = items.resolve(db, "house credits").item
eq("curated-only name", r.name, "House Credits"); eq("unverified", r.verified, false); eq("default cap", r.max, nil)
r = items.resolve(db, "cash").item
eq("generated display name", r.name, "Solari"); eq("cap", r.max, 1000000); eq("verified", r.verified, true)
r = items.resolve(db, "glow stick").item
eq("generated-only verified is nil", r.verified, nil)
eq("suggestion names", items.resolve(db, "solary").candidates[1].name, "Solari")
-- At most five suggestions.
local many = {}
for i = 1, 9 do many[i] = { "Rock" .. i, "Rock Type " .. i, "0" } end
local rocks = items.resolve(items.build({}, items.parse_generated(tsv(many))), "rock type")
eq("suggestions capped", #rocks.candidates, 5)
eq("more counted", rocks.more, 4)

-- The curated file shipped in the repo: parses cleanly, and no alias names two different items.
do
	local f = assert(io.open("data/items.tsv", "rb")); local text = f:read("*a"); f:close()
	local list, errs = items.parse_curated(text)
	eq("data/items.tsv errors", #errs, 0)
	for _, e in ipairs(errs) do fail("data/items.tsv " .. e) end
	local owner = {}
	for _, e in ipairs(list) do
		for _, a in ipairs(e.aliases) do
			local n = items.normalize(a)
			if owner[n] and owner[n] ~= e.id then fail("alias " .. a .. " names both " .. owner[n] .. " and " .. e.id) end
			owner[n] = e.id
		end
	end
	local d = items.build(list, nil)
	for q, id in pairs({ ["emf generator"] = "FremenComponent1", solari = "SolarisCoin", gold = "SolarisCoin", coins = "SolarisCoin",
		["sandbike psu"] = "SandbikeGenerator_1", ["sandbike treads"] = "SandbikeLocomotion_1", fuel = "FuelCanister_Large",
		["light darts"] = "Ammo", ["heavy darts"] = "HeavyAmmo", ["karpov 38"] = "HarkAr2", ["raider tokens"] = "EventRaiderToken" }) do
		eq("data/items.tsv " .. q, outcome(d, q), "item:" .. id)
	end
	eq("solari cap", items.resolve(d, "solari").item.max, 1000000)
	eq("emf verified", items.resolve(d, "emf generator").item.verified, true)
	eq("raider tokens unverified", items.resolve(d, "raider tokens").item.verified, false)
end

os.exit(failures == 0 and 0 or 1)
