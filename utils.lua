---Utils
local utils = {}

function utils.clamp(x, limit)
	return math.min(math.max(0, x), limit)
end

function utils.isInside(x, y, limitX, limitY)
	return (x >= 0 and x <= limitX) and (y >= 0 and y <= limitY)
end

function utils.map(t, f)
	local res = {}
	for key, value in pairs(t) do
		res[key] = f(value)
	end
	return res
end

function utils.all(t, f)
	local res = true
	f = f or function(v)
		return v
	end
	for _, v in pairs(t) do
		res = res and f(v)
	end
	return res
end

return utils
