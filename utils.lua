---Utils
local utils = {}

---Return x if it is between 0 and limit
---Else returns the closest of the two
---@param x number
---@param limit number
---@return number
function utils.clamp(x, limit)
	return math.min(math.max(0, x), limit)
end

---@return boolean
function utils.isInside(x, y, limitX, limitY)
	return (x >= 0 and x <= limitX) and (y >= 0 and y <= limitY)
end

---Map all values in t to their image through f
---Keeps the keys from t
---@param t table
---@param f function
---@return table
function utils.map(t, f)
	local res = {}
	for key, value in pairs(t) do
		res[key] = f(value)
	end
	return res
end

---Accumulate the values in a table given an op and a start value
---@generic T
---@param t table<any, T>
---@param op function(a:T,b:T):T
---@param start T
---@return T
function utils.accum(t, op, start)
	if not start then
		error("nil initial value")
	end
	local res = start
	for _, v in pairs(t) do
		res = op(res, v)
	end
	return res
end

---Return true if all the elements in a table are trueish
---@param t table
function utils.all(t)
	return utils.accum(t, function(a, b)
		return a and b
	end, true)
end

---Sum the values in a table
---@generic T
---@param t table<any, T>
---@param start T
---@return T
function utils.sum(t, start)
	return utils.accum(t, function(a, b)
		return a + b
	end, start)
end

---Pick a random element from t
---@param t table
---@return any
function utils.pick(t)
	if #t == 0 then
		error("list of length 0")
	elseif #t == 1 then
		return t[1]
	end
	for _, v in pairs(t) do
		if math.random() < 1 / #t then
			return v
		end
	end
end

---Dot product of lists
---@alias vector table<number, number> list of numbers
---@param u vector
---@param v vector
---@return number
function utils.dot(u, v)
	if #u ~= #v then
		error("vector dimension mismatch")
	end
	local prod = {}
	for i = 1, #u do
		prod[i] = u[i] * v[i]
	end
	return utils.sum(prod, 0)
end

function utils.dot2(u, v)
	return utils.dot({ u.x, u.y }, { v.x, v.y })
end

return utils
