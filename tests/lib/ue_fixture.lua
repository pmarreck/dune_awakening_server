-- Synthetic Unreal legacy packages (.uasset + .uexp) shaped like the game's item tables and string tables, for testing
-- libexec/lib/ue_assets.lua and dune-items without Funcom's content. Writer side of the format only: package summary
-- (file version -8, unversioned engine version, no custom versions), name map, tagged properties, DataTable rows and
-- a StringTable body. As a script: luajit tests/lib/ue_fixture.lua DIR writes a small tree under DIR.
local M = {}

local function u32(v) v = v % 2^32; return string.char(v % 256, math.floor(v / 256) % 256, math.floor(v / 65536) % 256, math.floor(v / 16777216) % 256) end
local function fstring(s)
	if s == "" then return u32(0) end
	if not s:find("[\128-\255]") then return u32(#s + 1) .. s .. "\0" end
	-- Non-ASCII: UTF-16LE with a negative length, as the engine writes it.
	local units = {}
	local i = 1
	while i <= #s do
		local c = s:byte(i)
		local cp, n
		if c < 0x80 then cp, n = c, 1 elseif c < 0xE0 then cp, n = (c % 0x20) * 64 + s:byte(i + 1) % 64, 2
		elseif c < 0xF0 then cp, n = ((c % 0x10) * 64 + s:byte(i + 1) % 64) * 64 + s:byte(i + 2) % 64, 3
		else cp, n = (((c % 8) * 64 + s:byte(i + 1) % 64) * 64 + s:byte(i + 2) % 64) * 64 + s:byte(i + 3) % 64, 4 end
		if cp >= 0x10000 then cp = cp - 0x10000; units[#units + 1] = 0xD800 + math.floor(cp / 1024); units[#units + 1] = 0xDC00 + cp % 1024
		else units[#units + 1] = cp end
		i = i + n
	end
	units[#units + 1] = 0
	local out = { u32(-#units) }
	for _, u in ipairs(units) do out[#out + 1] = string.char(u % 256, math.floor(u / 256)) end
	return table.concat(out)
end
M.fstring = fstring

-- A package: names are interned as they are used; finish() returns the .uasset and .uexp bytes.
function M.package(folder)
	local P = { names = {}, index = {} }
	function P.name(s, number)
		if not P.index[s] then P.names[#P.names + 1] = s; P.index[s] = #P.names - 1 end
		return u32(P.index[s]) .. u32(number or 0)
	end
	P.name("None")
	-- Tagged property: name, type, size, array index, type-specific tag data, no property guid, then the value.
	function P.prop(name, typ, value, tagdata)
		return P.name(name) .. P.name(typ) .. u32(#value) .. u32(0) .. (tagdata or "") .. "\0" .. value
	end
	-- The same with a property guid (flag 1, then 16 bytes) before the value.
	function P.prop_guid(name, typ, value)
		return P.name(name) .. P.name(typ) .. u32(#value) .. u32(0) .. "\1" .. string.rep("\7", 16) .. value
	end
	function P.struct(name, struct_name, body) return P.prop(name, "StructProperty", body, P.name(struct_name) .. string.rep("\0", 16)) end
	function P.bool(name, v) return P.name(name) .. P.name("BoolProperty") .. u32(0) .. u32(0) .. string.char(v and 1 or 0) .. "\0" end
	function P.int(name, v) return P.prop(name, "IntProperty", u32(v)) end
	function P.text_st(name, table_id, key)
		return P.prop(name, "TextProperty", u32(0) .. "\11" .. P.name(table_id) .. fstring(key))
	end
	function P.text_base(name, source)
		return P.prop(name, "TextProperty", u32(0) .. "\0" .. fstring("") .. fstring("0123ABCD") .. fstring(source))
	end
	function P.none() return P.name("None") end
	function P.finish(body)
		local names = {}
		for _, n in ipairs(P.names) do names[#names + 1] = fstring(n) .. u32(0) end
		local head = u32(0x9E2A83C1) .. u32(-8) .. u32(0) .. u32(0) .. u32(0) .. u32(0) .. u32(0) .. u32(0) .. fstring(folder) .. u32(0x80000000)
		local offset = #head + 8
		local uasset = head .. u32(#P.names) .. u32(offset) .. table.concat(names)
		return uasset, body .. u32(0x9E2A83C1)
	end
	return P
end

-- An item table (DT_BaseItems_*): rows = {{id, number, key or source, table, deprecated}...}.
function M.item_table(rows)
	local P = M.package("/Game/Fixture/DT_BaseItems_Fixture")
	local body = { P.prop("RowStruct", "ObjectProperty", u32(7)), P.bool("bIgnoreExtraFields", true), P.none(), u32(0), u32(#rows) }
	for _, r in ipairs(rows) do
		local static = {
			P.prop("Icon", "SoftObjectProperty", string.rep("\1", 20)),
			P.prop_guid("ItemSize", "FloatProperty", string.rep("\0", 4)),
			r.source and P.text_base("Name", r.source) or r.key and P.text_st("Name", r.table, r.key) or "",
			r.key and P.text_st("ShortDesc", r.table, r.key .. "_SHORT") or "",
			P.struct("ItemTags", "GameplayTagContainer", string.rep("\2", 20)),
			P.prop("CharacterStateTags", "SetProperty", string.rep("\0", 8), P.name("StructProperty")),
			P.prop("BaseAdditionalCurrencyPrices", "MapProperty", string.rep("\0", 8), P.name("StructProperty") .. P.name("IntProperty")),
			P.prop("SubInventoryType", "EnumProperty", P.name("EInventoryType::None"), P.name("EInventoryType")),
			P.bool("bIsEnabled", true), P.int("MaxQuantity", -1), P.none(),
		}
		body[#body + 1] = P.name(r.id, r.number)
		body[#body + 1] = P.prop("IconLayers", "ArrayProperty", u32(0), P.name("StructProperty"))
		body[#body + 1] = P.struct("StaticData", "GameItemStaticData", table.concat(static))
		body[#body + 1] = P.struct("StackAndDurability", "ItemStackAndDurabilityStats", P.int("MaxStackSize", 500) .. P.none())
		body[#body + 1] = P.bool("bIsDeprecated", r.deprecated)
		body[#body + 1] = P.none()
	end
	return P.finish(table.concat(body))
end

-- A string table: namespace and {key, value} pairs in order.
function M.string_table(namespace, entries)
	local P = M.package("/Game/Fixture/" .. namespace)
	local body = { P.none(), u32(0), fstring(namespace), u32(#entries) }
	for _, e in ipairs(entries) do body[#body + 1] = fstring(e[1]) .. fstring(e[2]) end
	body[#body + 1] = u32(0)
	return P.finish(table.concat(body))
end

local ITEMS = "/Game/Dune/Localization/ST_Localization_Items.ST_Localization_Items"
local BUILDINGS = "/Game/Dune/Localization/ST_Localization_Buildings.ST_Localization_Buildings"
M.ITEMS_TABLE = ITEMS
M.TABLES = {
	DT_BaseItems_Resources = {
		{ id = "FremenComponent1", key = "ITEMS/RESOURCE_EMF_GENERATOR_NAME", table = ITEMS },
		{ id = "D_FremenComponent3", key = "ITEMS/RESOURCE_FREMENCOMPONENT3_NAME", table = ITEMS, deprecated = true },
		{ id = "SolarisCoin", key = "ITEMS/RESOURCE_SOLARIS_COIN_NAME", table = ITEMS },
		{ id = "Nameless" },
		{ id = "LostKey", key = "ITEMS/NOT_IN_ANY_TABLE", table = ITEMS },
	},
	DT_BaseItems_Vehicles = {
		{ id = "SandbikeChassis", number = 2, key = "BUILDINGS/VEHICLE_SANDBIKECHASSIS1_ITEMNAME", table = BUILDINGS },
		{ id = "TestThing", source = "Base  Text\nThing" },
		{ id = "Creme", key = "ITEMS/CREME_NAME", table = ITEMS },
	},
}
M.STRINGS = {
	ST_Localization_Items = {
		{ "ITEMS/RESOURCE_EMF_GENERATOR_NAME", "EMF Generator" }, { "ITEMS/RESOURCE_FREMENCOMPONENT3_NAME", "EMF Generator" },
		{ "ITEMS/RESOURCE_SOLARIS_COIN_NAME", "Solari" }, { "ITEMS/CREME_NAME", "Crème \240\159\144\155 Brûlée \226\130\172" },
	},
	ST_Localization_Buildings = { { "BUILDINGS/VEHICLE_SANDBIKECHASSIS1_ITEMNAME", "Sandbike\r\nChassis" } },
}

-- write(dir): the tree retoc to-legacy would produce, at the game's paths.
function M.write(dir)
	local function put(path, data)
		os.execute("mkdir -p '" .. path:match("^(.*)/") .. "'")
		local f = assert(io.open(path, "wb")); f:write(data); f:close()
	end
	for name, rows in pairs(M.TABLES) do
		local a, x = M.item_table(rows)
		put(dir .. "/DuneSandbox/Content/Dune/Systems/Items/BaseItems/" .. name .. ".uasset", a)
		put(dir .. "/DuneSandbox/Content/Dune/Systems/Items/BaseItems/" .. name .. ".uexp", x)
	end
	for name, entries in pairs(M.STRINGS) do
		local a, x = M.string_table(name, entries)
		put(dir .. "/DuneSandbox/Content/Dune/Localization/" .. name .. ".uasset", a)
		put(dir .. "/DuneSandbox/Content/Dune/Localization/" .. name .. ".uexp", x)
	end
end

if arg and arg[0] and arg[0]:match("ue_fixture%.lua$") and arg[1] then M.write(arg[1]) end
return M
