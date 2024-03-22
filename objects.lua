local bullet = {
	new = function(self, pos, angle, color)
		local o = {
			pos = pos,
			angle = angle,
			vector = { x = math.cos(angle), y = math.sin(angle) },
			-- TODO: implement color for bullets
			color = color,
			speed = 1,
		}
		self.__index = self
		return setmetatable(o, self)
	end,
}

local enemy = {}
function enemy:new(w, h)
	local bare = { time_since_shot = 0.0, shooting_delay = 1.0, spawn_time = 2.0, width = 400, height = 400 }

	self.__index = self
	setmetatable(bare, self)

	-- FIX: Init pos at random on screen's edge
	-- FIX: Init firing angle, depends on pos
	self.pos = { x = -w / 2, y = -h / 2 }
	self.shooting_angle = math.atan2(h, w)
	self.remaining = 20

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
