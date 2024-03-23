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
function enemy.randomize_pos(w, h)
	local x
	local y
	if math.random() < 0.5 then
		-- pick either top or bottom and randomize x
		y = math.random() < 0.5 and -h / 2 or h / 2
		-- avoid spawning in corners
		x = (math.random() * 1.9 - 1) * w
	else
		-- pick either left or right and randomize y
		x = math.random() < 0.5 and -w / 2 or w / 2
		-- avoid spawning in corners
		y = (math.random() * 1.9 - 1) * h
	end
	return { x = x, y = y }
end
function enemy.init_shooting_angle(pos_x, pos_y)
	return math.pi + math.atan2(pos_y, pos_x)
end
function enemy:new(w, h, pos)
	local position = pos or enemy.randomize_pos(w, h)
	local bare = {
		time_since_shot = 0.0,
		shooting_delay = 1,
		pos = position,
		shooting_angle = enemy.init_shooting_angle(position.x, position.y),
		remaining = 5,
		color = math.random(2),
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
function ship.turn()
	ship.orientation = ship.orientation % 4 + 1
end

return { ship = ship, bullet = bullet, enemy = enemy }
