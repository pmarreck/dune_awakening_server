-- Unit tests for libexec/lib/ue_assets.lua (run by tests/unit/ue-assets) against synthetic packages from
-- tests/lib/ue_fixture.lua: name maps, tagged properties, DataTable rows, string tables, and the generated item list.
package.path = "libexec/lib/?.lua;tests/lib/?.lua;" .. package.path
local ue = require("ue_assets")
local fx = require("ue_fixture")
local failures = 0
local function fail(msg) io.stderr:write("FAIL ", msg, "\n"); failures = failures + 1 end
local function eq(name, got, want)
	if got ~= want then fail(string.format("%s: got %s, want %s", name, tostring(got), tostring(want))) end
end

-- String tables: ASCII and UTF-16 values come back as UTF-8.
local sa, sx = fx.string_table("ST_Localization_Items", fx.STRINGS.ST_Localization_Items)
local st, err = ue.string_table(sa, sx)
eq("string table error", err, nil)
eq("namespace", st and st.namespace, "ST_Localization_Items")
eq("plain value", st and st.entries["ITEMS/RESOURCE_SOLARIS_COIN_NAME"], "Solari")
eq("utf-16 value", st and st.entries["ITEMS/CREME_NAME"], "Crème \240\159\144\155 Brûlée \226\130\172")

-- Item rows: id (FName number suffix n shows as _n-1), the Name text's string table and key (or its inline source
-- text), and the deprecated flag; other properties of every shape are skipped by their sizes.
local ia, ix = fx.item_table(fx.TABLES.DT_BaseItems_Vehicles)
local rows
rows, err = ue.item_rows(ia, ix)
eq("item rows error", err, nil)
eq("row count", rows and #rows, 3)
if rows then
	eq("number suffix", rows[1].id, "SandbikeChassis_1")
	eq("table id", rows[1].table, "/Game/Dune/Localization/ST_Localization_Buildings.ST_Localization_Buildings")
	eq("key", rows[1].key, "BUILDINGS/VEHICLE_SANDBIKECHASSIS1_ITEMNAME")
	eq("inline text", rows[2].text, "Base  Text\nThing")
	eq("not deprecated", rows[1].deprecated, false)
end
ia, ix = fx.item_table(fx.TABLES.DT_BaseItems_Resources)
rows = ue.item_rows(ia, ix)
eq("deprecated", rows and rows[2].deprecated, true)
eq("no name", rows and rows[4].key, nil)

-- Refusals: not a package, an unsupported file version, a truncated body.
eq("not a package", select(2, ue.item_rows("garbage", ix)), "not an Unreal package")
local bad = sa:sub(1, 4) .. "\249\255\255\255" .. sa:sub(9)
eq("file version", select(2, ue.string_table(bad, sx)), "unsupported package file version -7")
local r2, e2 = ue.item_rows(ia, ix:sub(1, 200))
eq("truncated rows", r2, nil)
if not (e2 or ""):find("truncated", 1, true) then fail("truncated body error: " .. tostring(e2)) end

-- The generated list: one line per named row, sorted by id, names flattened to one line; unnamed rows and keys
-- missing from every string table are counted, not listed.
local tables = {}
for name, entries in pairs(fx.STRINGS) do tables[#tables + 1] = assert(ue.string_table(fx.string_table(name, entries))) end
local all = {}
for name, list in pairs(fx.TABLES) do
	local rs = assert(ue.item_rows(fx.item_table(list)))
	for _, r in ipairs(rs) do r.category = name:match("^DT_BaseItems_(.*)$"); all[#all + 1] = r end
end
local text, stats = ue.generated_tsv(all, tables)
local body = text:gsub("^#[^\n]*\n", "")
eq("generated list", body, table.concat({
	"Creme\tCrème \240\159\144\155 Brûlée \226\130\172\t0\tVehicles",
	"D_FremenComponent3\tEMF Generator\t1\tResources",
	"FremenComponent1\tEMF Generator\t0\tResources",
	"SandbikeChassis_1\tSandbike Chassis\t0\tVehicles",
	"SolarisCoin\tSolari\t0\tResources",
	"TestThing\tBase Text Thing\t0\tVehicles",
}, "\n") .. "\n")
if not text:match("^# [^\n]*never commit") then fail("generated list lacks its private-content header: " .. text:sub(1, 80)) end
eq("named", stats.named, 6); eq("unnamed", stats.unnamed, 1); eq("missing keys", stats.missing, 1)

os.exit(failures == 0 and 0 or 1)
