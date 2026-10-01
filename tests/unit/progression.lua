-- Unit tests for libexec/lib/progression.lua (run by tests/unit/progression): the game's level curve (data/levels.tsv)
-- turned into XP totals per level, and XP amounts corrected for the world's GlobalXpMultiplier.
-- The level oracles are observations from this world, not values derived from the code (docs/admin.md, "Levels").
package.path = "libexec/lib/?.lua;" .. package.path
local progression = require("progression")
local failures = 0
local function fail(msg) io.stderr:write("FAIL ", msg, "\n"); failures = failures + 1 end
local function eq(name, got, want)
	if got ~= want then fail(string.format("%s: got %s, want %s", name, tostring(got), tostring(want))) end
end
local function read(path) local f = assert(io.open(path, "rb")); local s = f:read("*a"); f:close(); return s end

-- Parsing: curve, key time, value; comments and blank lines skipped; bad lines reported with their line number.
local curves, errors = progression.parse_curves("# c\n\nXPNeeded\t0\t0\nXPNeeded\t2\t100\nbad\nXPNeeded\tx\t1\nMaxLevel\t0\t3\n")
eq("parse errors", #errors, 2)
eq("parse error names line 5", (errors[1] or ""):find("line 5", 1, true) ~= nil, true)
eq("parse error names line 6", (errors[2] or ""):find("line 6", 1, true) ~= nil, true)
eq("parsed keys", #curves.XPNeeded, 2)
-- Linear interpolation between keys, constant beyond both ends (RCIM_Linear, RCCE_Constant).
for _, c in ipairs({ { 0, 0 }, { 1, 50 }, { 2, 100 }, { 5, 100 }, { -1, 0 } }) do
	eq("eval " .. c[1], progression.eval(curves.XPNeeded, c[1]), c[2])
end
local small = progression.levels(curves)
eq("small max level", small.max, 3)
eq("small totals", table.concat({ small.total[0], small.total[1], small.total[2], small.total[3] }, ","), "0,50,150,250")

-- The shipped table (keys from the game, docs/admin.md "Levels").
curves, errors = progression.parse_curves(read("data/levels.tsv"))
eq("data/levels.tsv parses cleanly", #errors, 0)
local L = progression.levels(curves)
eq("max level", L.max, 200)
-- Every key of the game's curve is reproduced exactly at its own level (round trip), and interpolated levels sit
-- between their neighbours: level 6 lies between keys 5:500 and 7:600, level 129 between 128:651 and 130:655.
for _, k in ipairs(curves.XPNeeded) do
	if k[1] >= 1 and k[1] <= L.max then eq("XP for level " .. k[1], L.total[k[1]] - L.total[k[1] - 1], k[2]) end
end
eq("XP for level 6", L.total[6] - L.total[5], 550)
eq("XP for level 129", L.total[129] - L.total[128], 653)
local increasing = true
for lvl = 1, L.max do if not (L.total[lvl] > L.total[lvl - 1]) then increasing = false end end
eq("totals strictly increase", increasing, true)
eq("total for level 12", L.total[12], 5390)
eq("total for level 13", L.total[13], 5990)

-- Observations on this world (TotalXPEarned from the database, level or skill points from the game):
-- 5806 XP was shown in game as about two thirds through level 12; 390 XP held 1 skill point; 7032 XP holds 13 skill
-- points (no edits); 9289 XP holds 37 skill points of which 20 were added by add-skill-points. Skill points come from
-- SkillPointsRewarded: one for each level from 2 up.
local at = progression.level_of(L, 5806)
eq("5806 XP level", at.level, 12)
eq("5806 XP about two thirds through", at.fraction > 0.6 and at.fraction < 0.72, true)
eq("5806 XP into level", at.into, 416)
eq("5806 XP span", at.span, 600)
for _, c in ipairs({ { 390, 1 }, { 7032, 13 }, { 9289, 37 - 20 } }) do
	local lvl = progression.level_of(L, c[1]).level
	eq(c[1] .. " XP skill points from levels", math.max(lvl - 1, 0), c[2])
end
-- Edges: exactly on a threshold is that level; below level 1 is level 0; at and past the top, the max level.
eq("level at 0 XP", progression.level_of(L, 0).level, 0)
eq("level at 39 XP", progression.level_of(L, 39).level, 0)
eq("level at 40 XP", progression.level_of(L, 40).level, 1)
eq("level at total[12]", progression.level_of(L, 5390).level, 12)
eq("level at total[12] - 1", progression.level_of(L, 5389).level, 11)
eq("level at the top", progression.level_of(L, L.total[200]).level, 200)
eq("level past the top", progression.level_of(L, L.total[200] * 2).level, 200)
eq("no span at the top", progression.level_of(L, L.total[200]).span, nil)

-- GlobalXpMultiplier from UserServerCustomSettings.ini, classified over a set of files: only an uncommented key in
-- the server's own section counts; a missing key is nil (the caller uses 1); an unusable value is an error.
local SECTION = "[/Script/DuneSandbox.UserServerCustomSettings]\n"
for _, c in ipairs({
	{ "shipped form", SECTION .. "; Possible values: 0 to 10\nGlobalXpMultiplier=1.500000\nCombatXp=1.000000\n", 1.5 },
	{ "spaces and CRLF", SECTION:gsub("\n", "\r\n") .. "GlobalXpMultiplier = 2\r\n", 2 },
	{ "zero", SECTION .. "GlobalXpMultiplier=0.000000\n", 0 },
	{ "last one wins", SECTION .. "GlobalXpMultiplier=2\nGlobalXpMultiplier=3\n", 3 },
	{ "commented out", SECTION .. ";GlobalXpMultiplier=4\n", nil },
	{ "hash comment", SECTION .. "#GlobalXpMultiplier=4\n", nil },
	{ "other section", "[Other]\nGlobalXpMultiplier=4\n", nil },
	{ "after another section", SECTION .. "[Other]\nGlobalXpMultiplier=4\n", nil },
	{ "similar key", SECTION .. "GlobalXpMultiplierX=4\nLandsraadSpecializationXpMultiplier=4\n", nil },
	{ "empty file", "", nil },
}) do
	local m, err = progression.multiplier(c[2])
	eq("multiplier " .. c[1], m, c[3])
	eq("multiplier " .. c[1] .. " error", err, nil)
end
for _, bad in ipairs({ "abc", "-1", "11", "", "1.5x" }) do
	local m, err = progression.multiplier(SECTION .. "GlobalXpMultiplier=" .. bad .. "\n")
	eq("multiplier " .. bad .. " rejected", m, nil)
	eq("multiplier " .. bad .. " has an error", type(err), "string")
end

-- XP to send so the player receives an amount after the multiplier. "nearest" for xp (measured 2026-09-30: an
-- award of 4150 added 6225 at x1.5); "up" for level, so rounding never leaves the player short of the threshold.
for _, c in ipairs({
	{ 4150, 1.5, "nearest", 2767 }, { 1000, 1, "nearest", 1000 }, { 1, 1.5, "nearest", 1 }, { 1, 10, "nearest", 1 },
	{ 6225, 1.5, "nearest", 4150 }, { 10, 1.5, "nearest", 7 }, { 1000, 0.5, "nearest", 2000 },
	{ 4151, 1.5, "up", 2768 }, { 6225, 1.5, "up", 4150 }, { 1100, 1.1, "up", 1000 }, { 184, 1.5, "up", 123 }, { 1, 10, "up", 1 },
}) do
	eq(string.format("to_send %d x%g %s", c[1], c[2], c[3]), progression.to_send(c[1], c[2], c[3]), c[4])
end
-- "up" never leaves the player short, even with float rounding, over a sweep of amounts and multipliers.
local short = 0
for _, m in ipairs({ 0.1, 0.3, 0.7, 1, 1.1, 1.5, 2.2, 3.3, 7.7, 10 }) do
	for amount = 1, 2000 do
		if math.floor(progression.to_send(amount, m, "up") * m + 1e-9) < amount then short = short + 1 end
	end
end
eq("'up' never short", short, 0)

os.exit(failures == 0 and 0 or 1)
