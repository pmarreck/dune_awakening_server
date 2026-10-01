-- Character progression for dune-character's xp and level commands. Pure: callers pass file contents in.
-- Levels come from the game's CurveTable SkillXPPerLevel (data/levels.tsv): XPNeeded at level L is the XP that takes a
-- character from level L-1 to L, starting from level 0 at 0 XP, so the XP total for level L is XPNeeded(1) + ... +
-- XPNeeded(L) (docs/admin.md, "Levels", has the evidence). XP sent through the server's AwardXP is multiplied by the
-- world's GlobalXpMultiplier (UserServerCustomSettings.ini), so amounts are divided by it before sending.
local M = {}

M.SETTINGS_SECTION = "/Script/DuneSandbox.UserServerCustomSettings"
M.MULTIPLIER_KEY = "GlobalXpMultiplier"
M.MULTIPLIER_MAX = 10 -- the range Funcom's shipped file documents: "0 to 10 (0 means no XP is gained)"
local EPSILON = 1e-9

local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end

-- parse_curves(text) -> {curve name = {{time, value}, ...} sorted by time}, errors. Lines are `curve<TAB>time<TAB>value`;
-- `#` comments and blank lines are skipped.
function M.parse_curves(text)
	local curves, errors, n = {}, {}, 0
	for line in ((text or "") .. "\n"):gmatch("([^\n]*)\n") do
		n = n + 1
		line = line:gsub("\r$", "")
		if trim(line) ~= "" and not line:match("^%s*#") then
			local name, t, v = line:match("^([%w_]+)\t([^\t]+)\t([^\t]+)$")
			t, v = tonumber(t), tonumber(v)
			if not (name and t and v) then errors[#errors + 1] = string.format("line %d: expected curve, level and value separated by tabs", n)
			else
				curves[name] = curves[name] or {}
				table.insert(curves[name], { t, v })
			end
		end
	end
	for _, keys in pairs(curves) do table.sort(keys, function(a, b) return a[1] < b[1] end) end
	return curves, errors
end

-- eval(keys, x): the curve at x, interpolated linearly between keys and constant beyond both ends, as Unreal's
-- FSimpleCurve does with RCIM_Linear and RCCE_Constant.
function M.eval(keys, x)
	if x <= keys[1][1] then return keys[1][2] end
	for i = 2, #keys do
		local a, b = keys[i - 1], keys[i]
		if x <= b[1] then return a[2] + (b[2] - a[2]) * (x - a[1]) / (b[1] - a[1]) end
	end
	return keys[#keys][2]
end

-- levels(curves) -> {max = top level, total = {[0] = 0, [L] = XP total to reach level L}}, a running sum of XPNeeded.
-- The top level is MaxLevel at 0 (the game's curve holds 200 there), else XPNeeded's last key.
-- complexity: O(max * keys)
function M.levels(curves)
	local xp = curves.XPNeeded
	local max = curves.MaxLevel and M.eval(curves.MaxLevel, 0) or xp[#xp][1]
	local total = { [0] = 0 }
	for l = 1, max do total[l] = total[l - 1] + M.eval(xp, l) end
	return { max = max, total = total }
end

-- level_of(levels, xp) -> {level, into = XP past that level's total, span = XP from it to the next (nil at the top),
-- fraction = into / span (nil at the top)}.
function M.level_of(levels, xp)
	local level = 0
	while level < levels.max and levels.total[level + 1] <= xp do level = level + 1 end
	local into = xp - levels.total[level]
	local span = level < levels.max and (levels.total[level + 1] - levels.total[level]) or nil
	return { level = level, into = into, span = span, fraction = span and into / span or nil }
end

-- multiplier(ini_text) -> GlobalXpMultiplier, or nil when the server's section does not set it (the caller then uses
-- 1), or nil, error when the value is not a number from 0 to MULTIPLIER_MAX. The last uncommented key wins, as in Unreal.
function M.multiplier(text)
	local section, raw
	for line in ((text or "") .. "\n"):gmatch("([^\n]*)\n") do
		line = line:gsub("\r$", "")
		local s = line:match("^%s*%[(.-)%]%s*$")
		if s then section = s
		elseif section == M.SETTINGS_SECTION then
			local k, v = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
			if k == M.MULTIPLIER_KEY then raw = v end
		end
	end
	if raw == nil then return nil end
	local m = (raw:match("^%d+%.?%d*$") or raw:match("^%.%d+$")) and tonumber(raw)
	if not m or m > M.MULTIPLIER_MAX then
		return nil, string.format("%s=%s is not a number from 0 to %d", M.MULTIPLIER_KEY, raw, M.MULTIPLIER_MAX)
	end
	return m
end

-- to_send(amount, multiplier, rounding) -> the whole amount to send so the player receives about `amount` after the
-- server multiplies it. rounding "nearest" rounds amount / multiplier half up; "up" rounds up, so the player never
-- receives less than amount (used to reach a level threshold). Never less than 1. multiplier must be above 0.
function M.to_send(amount, multiplier, rounding)
	local exact = amount / multiplier
	local sent = rounding == "up" and math.ceil(exact - EPSILON) or math.floor(exact + 0.5)
	return math.max(sent, 1)
end

return M
