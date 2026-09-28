-- Reader for the Unreal legacy packages (.uasset + .uexp, as `retoc to-legacy` writes them) that dune-items needs: the
-- item DataTables (DT_BaseItems_*) and the localization StringTables (ST_Localization_*). Pure: callers pass bytes.
-- Format: package summary (file version -8) -> name map; export body = tagged properties (FPropertyTag: name, type,
-- size, array index, type-specific tag data, property-guid flag) ending at None; a DataTable then holds a row count and
-- rows of (FName row name, tagged struct); a StringTable holds namespace, count and key/value FStrings.
-- An item's id is its row name; its display name is StaticData.Name, an FText whose StringTableEntry history (type 11)
-- names a string table and key (checked against known pairs: SolarisCoin = Solari, HarkAr2 = Karpov 38).
local M = {}

local PACKAGE_TAG = 0x9E2A83C1
local SUPPORTED_VERSION = -8
local TEXT_HISTORY_BASE, TEXT_HISTORY_STRING_TABLE = 0, 11

-- A bounds-checked little-endian reader over s; every overrun raises "truncated".
local function reader(s)
	local R = { s = s, p = 1 }
	function R.need(n) if R.p + n - 1 > #s then error({ msg = "truncated" }) end end
	function R.u8() R.need(1); local v = s:byte(R.p); R.p = R.p + 1; return v end
	function R.i32()
		R.need(4)
		local a, b, c, d = s:byte(R.p, R.p + 3); R.p = R.p + 4
		local v = a + b * 256 + c * 65536 + d * 16777216
		return v >= 2^31 and v - 2^32 or v
	end
	function R.skip(n) R.need(n); R.p = R.p + n end
	-- FString: int32 length with terminator; negative = UTF-16LE code units, returned as UTF-8.
	function R.fstring()
		local n = R.i32()
		if n == 0 then return "" end
		if n > 0 then R.need(n); local v = s:sub(R.p, R.p + n - 2); R.p = R.p + n; return v end
		n = -n; R.need(2 * n)
		local out, i = {}, 0
		while i < n - 1 do
			local u = s:byte(R.p + 2 * i) + 256 * s:byte(R.p + 2 * i + 1)
			i = i + 1
			if u >= 0xD800 and u < 0xDC00 and i < n - 1 then
				local lo = s:byte(R.p + 2 * i) + 256 * s:byte(R.p + 2 * i + 1)
				i = i + 1
				u = 0x10000 + (u - 0xD800) * 1024 + (lo - 0xDC00)
			end
			if u < 0x80 then out[#out + 1] = string.char(u)
			elseif u < 0x800 then out[#out + 1] = string.char(0xC0 + math.floor(u / 64), 0x80 + u % 64)
			elseif u < 0x10000 then out[#out + 1] = string.char(0xE0 + math.floor(u / 4096), 0x80 + math.floor(u / 64) % 64, 0x80 + u % 64)
			else out[#out + 1] = string.char(0xF0 + math.floor(u / 262144), 0x80 + math.floor(u / 4096) % 64, 0x80 + math.floor(u / 64) % 64, 0x80 + u % 64) end
		end
		R.p = R.p + 2 * n
		return table.concat(out)
	end
	return R
end

-- Package summary up to the name map: returns {package, names = {[0] = "None", ...}}.
local function summary(uasset)
	local R = reader(uasset)
	if R.i32() % 2^32 ~= PACKAGE_TAG then error({ msg = "not an Unreal package" }) end
	local version = R.i32()
	if version ~= SUPPORTED_VERSION then error({ msg = "unsupported package file version " .. version }) end
	R.skip(16) -- legacy UE3 version, UE4 version, UE5 version, licensee version (all 0: unversioned)
	R.skip(R.i32() * 20) -- custom versions: guid + version each
	R.skip(4) -- total header size
	local package = R.fstring()
	local flags = R.i32() % 2^32
	if math.floor(flags / 0x2000) % 2 == 1 then error({ msg = "unversioned properties (no schema to read them with)" }) end
	local count, offset = R.i32(), R.i32()
	R.p = offset + 1
	local names = {}
	for i = 0, count - 1 do names[i] = R.fstring(); R.skip(4) end
	return { package = package, names = names }
end

-- FName: name-map index and number; number n > 0 displays as "<name>_<n-1>".
local function fname(R, names)
	local idx, num = R.i32(), R.i32()
	local n = names[idx]
	if not n then error({ msg = "bad name index " .. idx .. " (not a package this reader understands)" }) end
	return num > 0 and (n .. "_" .. (num - 1)) or n
end

-- Walk tagged properties until None, calling visit(name, type, struct_name, bool_value, value_start, size) for each;
-- the reader is left after None. visit may read at value_start; the walk always resumes at value_start + size.
local function properties(R, names, visit)
	while true do
		local name = fname(R, names)
		if name == "None" then return end
		local typ = fname(R, names)
		local size = R.i32(); R.skip(4)
		local struct_name, bool
		if typ == "StructProperty" then struct_name = fname(R, names); R.skip(16)
		elseif typ == "BoolProperty" then bool = R.u8() ~= 0
		elseif typ == "ByteProperty" or typ == "EnumProperty" or typ == "ArrayProperty" or typ == "SetProperty" or typ == "OptionalProperty" then fname(R, names)
		elseif typ == "MapProperty" then fname(R, names); fname(R, names) end
		if R.u8() ~= 0 then R.skip(16) end
		local start = R.p
		R.need(size)
		if visit then visit(name, typ, struct_name, bool, start, size) end
		R.p = start + size
	end
end

local function protect(f)
	local ok, a, b = pcall(f)
	if ok then return a, b end
	if type(a) == "table" then return nil, a.msg end
	error(a, 0)
end

-- string_table(uasset, uexp) -> {name, namespace, entries = {key = value}} or nil, error.
function M.string_table(uasset, uexp)
	return protect(function()
		local sum = summary(uasset)
		local R = reader(uexp)
		properties(R, sum.names)
		R.skip(4) -- object guid flag
		local st = { name = sum.package:match("([^/]*)$"), namespace = R.fstring(), entries = {} }
		for _ = 1, R.i32() do local k = R.fstring(); st.entries[k] = R.fstring() end
		return st
	end)
end

-- item_rows(uasset, uexp) -> {{id, table, key, text, deprecated}...} or nil, error. table/key: the string table entry
-- naming the item; text: an inline name (Base history) instead.
function M.item_rows(uasset, uexp)
	return protect(function()
		local sum = summary(uasset)
		local names = sum.names
		local R = reader(uexp)
		properties(R, names)
		R.skip(4) -- object guid flag
		local rows = {}
		for _ = 1, R.i32() do
			local row = { id = fname(R, names), deprecated = false }
			properties(R, names, function(name, typ, struct_name, bool, start)
				if name == "bIsDeprecated" and typ == "BoolProperty" then row.deprecated = bool
				elseif struct_name == "GameItemStaticData" then
					local S = reader(uexp); S.p = start
					properties(S, names, function(n2, t2, _, _, s2)
						if n2 == "Name" and t2 == "TextProperty" then
							local T = reader(uexp); T.p = s2
							T.skip(4) -- text flags
							local history = T.u8()
							if history == TEXT_HISTORY_STRING_TABLE then row.table = fname(T, names); row.key = T.fstring()
							elseif history == TEXT_HISTORY_BASE then T.fstring(); T.fstring(); row.text = T.fstring() end
						end
					end)
				end
			end)
			rows[#rows + 1] = row
		end
		return rows
	end)
end

local function flatten(s) return (s:gsub("%s+", " "):gsub("^ ", ""):gsub(" $", "")) end

-- generated_tsv(rows, string_tables) -> text, {named, unnamed, missing}. Lines `id<TAB>name<TAB>0|1 (deprecated)
-- <TAB>category`, sorted by id, after a header comment; the format lib/items.lua parse_generated reads.
function M.generated_tsv(rows, string_tables)
	local by_name = {}
	for _, st in ipairs(string_tables) do by_name[st.name] = st end
	local stats, lines = { named = 0, unnamed = 0, missing = 0 }, {}
	for _, r in ipairs(rows) do
		local name = r.text
		if r.key then
			local st = by_name[(r.table or ""):match("([^.]*)$")]
			name = st and st.entries[r.key]
			if not name then stats.missing = stats.missing + 1 end
		elseif not r.text then stats.unnamed = stats.unnamed + 1 end
		name = name and flatten(name)
		if name and name ~= "" then
			stats.named = stats.named + 1
			lines[#lines + 1] = table.concat({ r.id, name, r.deprecated and "1" or "0", r.category or "" }, "\t")
		end
	end
	table.sort(lines)
	return "# Item names from the game's own tables (dune-items refresh). Derived from Funcom's content: private, never commit.\n"
		.. table.concat(lines, "\n") .. (#lines > 0 and "\n" or ""), stats
end

return M
