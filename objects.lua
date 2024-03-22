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

local enemy = {}
function enemy.new(w, h)
	local bare = { time_since_shot = 0.0, shooting_delay = 1.0, spawn_time = 2.0, width = 400, height = 400 }

	-- FIX: Init pos at random on screen's edge
	-- FIX: Init firing angle, depends on pos
	bare.pos = { x = -w / 2, y = -h / 2 }
	bare.shooting_angle = math.atan2(h, w)
	bare.remaining = 20
	return bare
end

local ship = { health = 100, orientation = 1, step = 10 }

---turn ship
---default is pi/2 clockwise
function ship.turn(w)
	local way = w or 1
	ship.orientation = ship.orientation % 4 + way
end

return { ship = ship, bullet = bullet, enemy = enemy }
