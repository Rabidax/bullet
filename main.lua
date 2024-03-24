function love.load()
	-- set graphics stuff
	Width, Height = love.graphics.getDimensions()
	LastSpawnTime = love.timer.getTime()

	-- load objects
	utils = require("utils")
	parse_level = require("parser").parse
	Ship = require("objects").ship
	Enemy = require("objects").enemy
	Bullet = require("objects").bullet

	Ship.sprite = love.graphics.newImage("assets/ship_tmp.jpg")
	Enemies = {}
	Bullets = {}

	Colors = { { 1, 1, 1 }, { 1, 0, 0 } }

	Play = false
	Debug = false

	-- Pick a level
	-- TODO: implement level choice UI
	Level = parse_level("lvl_test")
	Play = true
end

function love.update(dt)
	-- HACK: for hotswapping during dev
	require("lurker").update()

	if not Play then
		return
	end

	-- TODO: make an iterator for level that returns events in time order
	for k, events in ipairs(Level) do
		local time, enemies = unpack(events)
		if love.timer.getTime() >= time then
			if not Level[k].done then
				for _, e in pairs(enemies) do
					Enemies[#Enemies + 1] = Enemy:new(Width, Height, e)
				end
				Level[k].done = true
			end
		end
	end
	if Ship.health <= 0 then
		love.event.quit("restart")
	end

	-- Update enemies
	if #Enemies >= 1 then
		for n, enemy in pairs(Enemies) do
			if enemy.remaining <= 0 then
				-- remove enemies without bullet
				table.remove(Enemies, n)
			elseif love.timer.getTime() - enemy.time_since_shot > enemy.shooting_delay then
				-- shoot
				Bullets[#Bullets + 1] = Bullet:new(enemy:get_pos(), enemy.shooting_angle, enemy.color)
				enemy.remaining = enemy.remaining - 1
				enemy.time_since_shot = love.timer.getTime()
			end
		end
	end

	-- Update bullets
	local width = Ship.sprite:getWidth()
	local height = Ship.sprite:getHeight()
	local min_ship_size = math.min(width / 2, height / 2)
	for n, b in pairs(Bullets) do
		-- FIX: tighten ship hitbox ?
		local bullet_inf_norm = math.max(math.abs(b.pos.x), math.abs(b.pos.y))
		if bullet_inf_norm >= min_ship_size then
			-- bullet didn't reach player, so move it
			b.pos.x = b.pos.x + b.speed * b.vector.x
			b.pos.y = b.pos.y + b.speed * b.vector.y
		else
			-- if bullet isn't eaten, take damage
			local orientation = math.pi / 2 * (Ship.orientation - 1)
			local ship_vector = { x = math.cos(orientation), y = math.sin(orientation) }
			local touched_color = utils.dot2(b.vector, ship_vector) < 0 and 1 or 2
			local eaten_bullet = touched_color == b.color
			if not eaten_bullet then
				Ship.health = Ship.health - 1
			end
			-- then remove bullet
			table.remove(Bullets, n)
		end
	end
end
function love.draw()
	-- Instructions
	local instructions = "F : turn | Q : quit" .. "\n" .. "Health : " .. Ship.health
	love.graphics.print(instructions)
	local debug = #Enemies
		.. " active enemies, they have "
		.. (#Enemies >= 1 and utils.sum(
			utils.map(Enemies, function(e)
				return e.remaining
			end),
			0
		) or "no")
		.. " bullets"
	-- 	.. "\n"
	-- 	.. "There is "
	-- 	.. #Bullets
	-- 	.. " bullets on the stack"
	-- 	.. "\n"
	-- 	.. tostring(utils.all(
	-- 		utils.map(Bullets, function(b)
	-- 			return b.pos
	-- 		end),
	-- 		function(v)
	-- 			return v == Enemies[1].pos
	-- 		end
	-- 	) and "All bullets are on the enemy pos" or "")
	if Debug then
		print(debug)
	end

	-- Draw ship
	local width = Ship.sprite:getWidth()
	local height = Ship.sprite:getHeight()
	local orientation = math.pi / 2 * Ship.orientation
	love.graphics.draw(Ship.sprite, Width / 2, Height / 2, orientation, 1, 1, width / 2, height / 2)

	for _, e in pairs(Enemies) do
		love.graphics.translate(Width / 2, Height / 2)
		love.graphics.setColor(Colors[e.color])
		love.graphics.circle("fill", e.pos.x, e.pos.y, 8)
		love.graphics.line(
			e.pos.x,
			e.pos.y,
			e.pos.x + 20 * math.cos(e.shooting_angle),
			e.pos.y + 20 * math.sin(e.shooting_angle)
		)
		love.graphics.setColor(1, 1, 1)
		love.graphics.origin()
	end

	-- Draw all the bullets
	for n, b in pairs(Bullets) do
		if not utils.isInside(b.pos.x + Width / 2, b.pos.y + Height / 2, Width, Height) then
			table.remove(Bullets, n)
		else
			love.graphics.translate(Width / 2, Height / 2)
			love.graphics.setColor(Colors[b.color])
			love.graphics.circle("fill", b.pos.x, b.pos.y, 2)
			love.graphics.setColor(1, 1, 1)
			love.graphics.origin()
		end
	end
end

function love.keyreleased(key)
	if key == "q" then
		love.event.quit()
	elseif key == "f" then
		Ship.turn()
	elseif key == "d" then
		Ship.turn(-1)
	end
end
