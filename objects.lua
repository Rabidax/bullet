local utils = require("utils")

local bullet = {
	new = function(self, pos, angle, color)
		local o = {
			pos = pos,
			angle = angle,
			vector = { x = math.cos(angle), y = math.sin(angle) },
			color = color,
			speed = 1,
		}
		self.__index = self
		return setmetatable(o, self)
	end,
}

local enemy = {
	spawn_time = 2,
}
-- everything here is in screen centered coords
function enemy.randomize_pos(w, h, pos)
	local x
	local y
	local sign = utils.pick({ -1, 1 })
	local percentage = sign * (math.random() * 0.7 + 0.1)

	if not pos then
		pos = utils.pick({ 1, 2, 3, 4 })
	end
	local sides = { w / 2, h / 2, -w / 2, -h / 2 }
	if pos == 1 or pos == 3 then
		-- pos provided is left or right
		x = sides[pos]
		y = percentage * h / 2
	else
		-- pos provided is top or bottom
		y = sides[pos]
		x = percentage * w / 2
	end
	return { x = x, y = y }
end
function enemy:new(w, h, e)
	local position = enemy.randomize_pos(w, h, e[1])
	local bare = {
		pos = position,
		color = e[2],
		remaining = e[3],
		shooting_delay = e[4],
		time_since_shot = 0.0,
		shooting_angle = math.pi + math.atan2(position.y, position.x),
	}

	self.__index = self
	setmetatable(bare, self)

	return bare
end
function enemy:get_pos()
	return { x = self.pos.x, y = self.pos.y }
end

local ship = { health = 100, orientation = 1, step = 10 }

---turn ship
---default is pi/2 clockwise
function ship.turn(w)
	local way = w or 1
	ship.orientation = ship.orientation % 4 + way
end

return { ship = ship, bullet = bullet, enemy = enemy }
