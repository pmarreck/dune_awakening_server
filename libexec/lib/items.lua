-- Item names for the chat bridge's &give: a curated list kept in the repo (data/items.tsv: id, verified, max count,
-- aliases) and a list generated privately from the game's own item tables (dune-items refresh: id, display name,
-- deprecated), merged into one lookup where the curated list wins. Pure: callers pass file contents in.
local M = {}
M.MAX_SUGGESTIONS = 5

local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
local function is_id(s) return s:match("^[%w_]+$") ~= nil end

-- normalize(s): the form names are compared in. Lowercase, apostrophes dropped, any other run of non-alphanumeric
-- characters one space, trimmed; so "Karpov-38" = "karpov 38" and "Flamegouger's" = "flamegougers".
function M.normalize(s)
	return trim((s:lower():gsub("['\226\128\153]", ""):gsub("[^%w]+", " ")))
end

local function lines(text)
	local n = 0
	local iter = ((text or "") .. "\n"):gmatch("([^\n]*)\n")
	return function()
		local l = iter()
		if l == nil then return nil end
		n = n + 1
		return n, (l:gsub("\r$", ""))
	end
end

local function fields(l)
	local out = {}
	for f in (l .. "\t"):gmatch("([^\t]*)\t") do out[#out + 1] = trim(f) end
	return out
end

-- parse_curated(text) -> entries, errors. Lines `id<TAB>yes|no<TAB>max count or -<TAB>alias|alias...`, `#` comments.
-- Entry: {id, verified = bool, max = number or nil (the default cap), aliases = {...}}.
function M.parse_curated(text)
	local entries, errors = {}, {}
	for n, l in lines(text) do
		if trim(l) ~= "" and not l:match("^%s*#") then
			local f = fields(l)
			local id, verified, max, aliases = f[1], f[2], f[3], {}
			for a in (f[4] or ""):gmatch("[^|]+") do if M.normalize(a) ~= "" then aliases[#aliases + 1] = trim(a) end end
			local err
			if #f ~= 4 then err = "expected id, verified, max count and aliases separated by tabs"
			elseif not is_id(id) then err = "not an item id: " .. id
			elseif verified ~= "yes" and verified ~= "no" then err = "verified must be yes or no"
			elseif max ~= "-" and not (max:match("^%d+$") and tonumber(max) >= 1) then err = "max count must be a whole number >= 1 or -"
			elseif #aliases == 0 then err = "no aliases" end
			if err then errors[#errors + 1] = string.format("line %d: %s", n, err)
			else entries[#entries + 1] = { id = id, verified = verified == "yes", max = max ~= "-" and tonumber(max) or nil, aliases = aliases } end
		end
	end
	return entries, errors
end

-- parse_generated(text) -> entries {id, name, deprecated}. Lines `id<TAB>display name<TAB>0|1`; others are skipped.
function M.parse_generated(text)
	local out = {}
	for _, l in lines(text) do
		local f = fields(l)
		if not l:match("^#") and #f >= 3 and is_id(f[1]) and f[2] ~= "" then
			out[#out + 1] = { id = f[1], name = f[2], deprecated = f[3] == "1" }
		end
	end
	return out
end

-- build(curated, generated) -> db. generated may be nil (no generated list yet); then a single id-shaped word that
-- names nothing is passed through as a raw id. A name the curated list uses belongs to its curated items only; among
-- generated items sharing a name, deprecated ones are dropped when a live one exists.
function M.build(curated, generated)
	local db = { by_id = {}, by_name = {}, has_generated = generated ~= nil }
	local function item(id)
		local k = id:lower()
		db.by_id[k] = db.by_id[k] or { id = id }
		return db.by_id[k]
	end
	for _, g in ipairs(generated or {}) do
		local it = item(g.id); it.name = it.name or g.name; it.deprecated = g.deprecated
	end
	local owned = {}
	local function add(n, id)
		local ids = db.by_name[n] or {}
		for _, x in ipairs(ids) do if x == id then return end end
		ids[#ids + 1] = id; db.by_name[n] = ids
	end
	for _, c in ipairs(curated or {}) do
		local it = item(c.id)
		it.verified, it.max, it.name = c.verified, c.max, it.name or c.aliases[1]
		for _, a in ipairs(c.aliases) do local n = M.normalize(a); owned[n] = true; add(n, c.id) end
	end
	local gen = {}
	for _, g in ipairs(generated or {}) do
		local n = M.normalize(g.name)
		if n ~= "" and not owned[n] then gen[n] = gen[n] or {}; table.insert(gen[n], g) end
	end
	for n, gs in pairs(gen) do
		local live = false
		for _, g in ipairs(gs) do if not g.deprecated then live = true end end
		for _, g in ipairs(gs) do if not (live and g.deprecated) then add(n, g.id) end end
	end
	return db
end

local function view(db, id)
	local it = db.by_id[id:lower()]
	return { id = it.id, name = it.name or it.id, max = it.max, verified = it.verified }
end

local function levenshtein(a, b)
	local prev = {}
	for j = 0, #b do prev[j] = j end
	for i = 1, #a do
		local cur, ai = { [0] = i }, a:byte(i)
		for j = 1, #b do
			cur[j] = math.min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (ai == b:byte(j) and 0 or 1))
		end
		prev = cur
	end
	return prev[#b]
end

local function words_prefix(qwords, key)
	for _, w in ipairs(qwords) do
		if not (" " .. key):find(" " .. w, 1, true) then return false end
	end
	return true
end

-- Up to MAX_SUGGESTIONS items whose names are closest to n: names containing it (spaces ignored), then names whose
-- words start with its words, then names within a small edit distance; shorter and nearer first.
local function suggest(db, n)
	local q, qwords = n:gsub(" ", ""), {}
	for w in n:gmatch("%S+") do qwords[#qwords + 1] = w end
	local limit = math.max(1, math.floor(#n / 3))
	local scored = {}
	for key, ids in pairs(db.by_name) do
		local tier, metric
		if q ~= "" and key:gsub(" ", ""):find(q, 1, true) then tier, metric = 1, #key
		elseif #qwords > 0 and words_prefix(qwords, key) then tier, metric = 2, #key
		elseif math.abs(#key - #n) <= limit then
			local d = levenshtein(n, key)
			if d <= limit then tier, metric = 3, d end
		end
		if tier then for _, id in ipairs(ids) do scored[#scored + 1] = { tier = tier, metric = metric, key = key, id = id } end end
	end
	table.sort(scored, function(a, b)
		if a.tier ~= b.tier then return a.tier < b.tier end
		if a.metric ~= b.metric then return a.metric < b.metric end
		if a.key ~= b.key then return a.key < b.key end
		return a.id < b.id
	end)
	local out, seen, more = {}, {}, 0
	for _, s in ipairs(scored) do
		if not seen[s.id] then
			seen[s.id] = true
			if #out < M.MAX_SUGGESTIONS then out[#out + 1] = view(db, s.id) else more = more + 1 end
		end
	end
	return out, more
end

-- resolve(db, query) -> {item = {id, name, max, verified, raw}} for exactly one item; otherwise {candidates = {...},
-- ambiguous = true when several items share the name, more = how many candidates were left out}. An exact item id
-- (any case) wins over names.
function M.resolve(db, query)
	local q = trim(query or "")
	if is_id(q) and db.by_id[q:lower()] then return { item = view(db, q) } end
	local n = M.normalize(q)
	local ids = db.by_name[n]
	if ids and #ids == 1 then return { item = view(db, ids[1]) } end
	if ids then
		local c = {}
		table.sort(ids)
		for i = 1, math.min(#ids, M.MAX_SUGGESTIONS) do c[i] = view(db, ids[i]) end
		return { candidates = c, ambiguous = true, more = math.max(0, #ids - M.MAX_SUGGESTIONS) }
	end
	if not db.has_generated and is_id(q) then return { item = { id = q, name = q, raw = true } } end
	local c, more = suggest(db, n)
	return { candidates = c, more = more }
end

return M
