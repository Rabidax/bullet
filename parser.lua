local utils = require("utils")
local parser = {}

---@alias timestamp number
---@alias enemy number[]
---@alias event {time:timestamp, enemies:enemy[]}
---@alias level event[]

---Read a level file from disk and parse it
---@param path string
---@return level
function parser.parse(path)
	---@type level
	local lvl = {}
	-- for line in love.filesystem.lines(path) do
	for line in io.lines(path) do
		local time, enemies = parser.parse_line(line)
		if time and enemies then
			table.insert(lvl, { time, enemies })
		end
	end
	table.sort(lvl, function(a, b)
		return a[1] < b[1]
	end)
	return lvl
end

---Parse line
---@param l string
---@return timestamp, enemy[]
function parser.parse_line(l)
	local min, sec = l:match("^(%d%d):(%d%d)")
	if not min or not sec then
		error("timestam parsing error")
	end
	---@type timestamp
	local time = utils.map({ min, sec }, tonumber)
	-- convert time in seconds
	time = utils.dot(time, { 60, 1 })
	-- NOTE: l should begin with 'xx:xx,' hence 7
	local line_rem = l:sub(7, #l)
	local enemies = {}
	-- NOTE: we expect in parens :
	-- single digit "side",
	-- single digit "type,
	-- integer "remaining bullets",
	-- number "delay"
	for s, t, r, d in line_rem:gmatch("%((%d),(%d),(%d+),(%d+%.%d+)%)") do
		if not utils.all({ s, t, r, d }) then
			error("level parsing error")
		end
		enemies[#enemies + 1] = utils.map({ s, t, r, d }, tonumber)
	end
	if #enemies == 0 then
		error("level parsing error : timestamp given, but no enemies found")
	end
	return time, enemies
end

return parser
