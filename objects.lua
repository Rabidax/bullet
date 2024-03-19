local bullet = {
	new = function(pos, angle, color)
		return {
			pos = pos,
			angle = angle,
			vector = { x = math.cos(angle), y = math.sin(angle) },
			color = color, -- TODO: implement color for bullets
			speed = 1,
		}
	end,
}

local enemy = { time_since_shot = 0.0, shooting_delay = 1.0, spawn_time = 2.0 }
---Initialize an enemy object
---To be used right after enemy:new()
function enemy:spawn(width, height)
	-- FIX: Init pos at random on screen's edge
	self.pos = { x = -width / 2, y = -height / 2 }
	-- FIX: Init firing angle, depends on pos
	self.shooting_angle = math.atan2(height, width)
	self.remaining = 20
	return self
end

---Creates a new enemy instance
function enemy:new(o)
	o = o or {}
	self.__index = self
	return setmetatable(o, self)
end

local ship = { health = 100, orientation = 1, step = 10 }

---turn ship
---default is pi/2 clockwise
function ship.turn(w)
	local way = w or 1
	ship.orientation = ship.orientation % 4 + way
end

return { ship = ship, bullet = bullet, enemy = enemy }
