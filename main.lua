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
	Enemies[1] = Enemy:new(Width, Height)
	Bullets = {}
end

function love.update(dt)
	-- FIX: spawn enemies
	--
	-- if love.timer.getTime() - LastSpawnTime > Enemy.spawn_time then
	-- 	Enemies[#Enemies + 1] = Enemy:new():spawn(Width, Height)
	-- 	LastSpawnTime = love.timer.getTime()
	-- end
	--

	-- Update enemies
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
			love.event.quit()
		end
	end
end
function love.draw()
	-- Instructions
	local instructions = "F : turn | Q : quit"
	love.graphics.print(instructions)
	local debug = #Enemies
		.. " active enemies, they have "
		.. Enemies[1].remaining
		.. " bullets"
		.. "\n"
		.. "There is "
		.. #Bullets
		.. " bullets on the stack"
		.. "\n"
		.. tostring(utils.all(
			utils.map(Bullets, function(b)
				return b.pos
			end),
			function(v)
				return v == Enemies[1].pos
			end
		) and "All bullets are on the enemy pos" or "")
	print(debug)

	-- Draw ship
	local width = Ship.sprite:getWidth()
	local height = Ship.sprite:getHeight()
	local orientation = math.pi / 2 * Ship.orientation
	love.graphics.draw(Ship.sprite, Width / 2, Height / 2, orientation, 1, 1, width / 2, height / 2)

	-- Draw all the bullets
	for _, b in pairs(Bullets) do
		love.graphics.translate(Width / 2, Height / 2)
		love.graphics.circle("fill", b.pos.x, b.pos.y, 2)
		love.graphics.origin()
	end
end

function love.keyreleased(key)
	if key == "q" then
		love.event.quit()
	elseif key == "f" then
		Ship.turn()
	end
end
