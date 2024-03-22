function love.load()
	-- set graphics stuff
	Width, Height = love.graphics.getDimensions()
	LastSpawnTime = love.timer.getTime()

	-- load objects
	utils = require("utils")
	Ship = require("objects").ship
	Enemy = require("objects").enemy
	Bullet = require("objects").bullet

	Ship.sprite = love.graphics.newImage("assets/ship.jpg")
	Enemies = {}
	Bullets = {}

	Debug = false
end

function love.update(dt)
	-- -- HACK: for hotswapping during dev
	-- require("lurker").update()

	-- FIX: enemies all spawn at the same pos
	if love.timer.getTime() - LastSpawnTime > Enemy.spawn_time then
		Enemies[#Enemies + 1] = Enemy:new(Width, Height)
		LastSpawnTime = love.timer.getTime()
	end

	-- Update enemies
	if #Enemies >= 1 then
		for n, enemy in pairs(Enemies) do
			if enemy.remaining <= 0 then
				-- remove enemies without bullet
				table.remove(Enemies, n)
			elseif love.timer.getTime() - enemy.time_since_shot > enemy.shooting_delay then
				-- shoot
				Bullets[#Bullets + 1] = Bullet:new(enemy:get_pos(), enemy.shooting_angle)
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
		local bullet_inf_norm = math.max(math.abs(b.pos.x), math.abs(b.pos.y))
		-- if bullet not reached player, progress, else quit
		if bullet_inf_norm >= min_ship_size then
			b.pos.x = b.pos.x + b.speed * b.vector.x
			b.pos.y = b.pos.y + b.speed * b.vector.y
		else
			-- love.event.quit()
		end
	end
end
function love.draw()
	-- Instructions
	local instructions = "F : turn | Q : quit"
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
		love.graphics.circle("fill", e.pos.x, e.pos.y, 8)
		love.graphics.line(
			e.pos.x,
			e.pos.y,
			e.pos.x + 20 * math.cos(e.shooting_angle),
			e.pos.y + 20 * math.sin(e.shooting_angle)
		)
		love.graphics.origin()
	end

	-- Draw all the bullets
	for n, b in pairs(Bullets) do
		if not utils.isInside(b.pos.x + Width / 2, b.pos.y + Height / 2, Width, Height) then
			table.remove(Bullets, n)
		else
			love.graphics.translate(Width / 2, Height / 2)
			love.graphics.circle("fill", b.pos.x, b.pos.y, 2)
			love.graphics.origin()
		end
	end
end

function love.keyreleased(key)
	if key == "q" then
		love.event.quit()
	elseif key == "f" then
		Ship.turn()
	end
end
