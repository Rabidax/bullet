-- Utils

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

-- Love stuff

function love.load()
	-- set graphics stuff
	Width, Height = love.graphics.getDimensions()
	LastSpawnTime = love.timer.getTime() -- load objects
	Ship = require("objects").ship
	Enemy = require("objects").enemy
	Bullet = require("objects").bullet

	Ship.sprite = love.graphics.newImage("assets/ship.jpg")
	Enemies = {}
	Enemies[#Enemies + 1] = Enemy:new():spawn(Width, Height)
	Bullets = {}

	Lost = false
end

function love.update(dt)
	-- FIX: enemy pos is in screen centered coords, messes with bullet movement

	-- FIX: spawn enemies
	--
	-- if love.timer.getTime() - LastSpawnTime > Enemy.spawn_time then
	-- 	Enemies[#Enemies + 1] = Enemy:new():spawn(Width, Height)
	-- 	LastSpawnTime = love.timer.getTime()
	-- end
	--

	for n, enemy in pairs(Enemies) do
		if enemy.remaining <= 0 then
			-- remove enemies without bullet
			table.remove(Enemies, n)
		elseif love.timer.getTime() - enemy.time_since_shot > enemy.shooting_delay then
			-- shoot
			Bullets[#Bullets + 1] = Bullet.new(enemy.pos, enemy.shooting_angle, { math.random(), math.random(), 0 })
			enemy.remaining = enemy.remaining - 1
			enemy.time_since_shot = love.timer.getTime()
		end
	end
	-- FIX: bullets are stacked on top of each other
	-- wrong bullet spawn or drawing if you will
	local width = Ship.sprite:getWidth()
	local height = Ship.sprite:getHeight()
	local min_ship_size = math.min(width / 2, height / 2)
	for n, b in ipairs(Bullets) do
		local bullet_inf_norm = math.max(math.abs(b.pos.x), math.abs(b.pos.y))
		-- if bullet not reached player, progress, else quit
		if bullet_inf_norm >= min_ship_size then
			b.pos.x = b.pos.x + b.speed * b.vector.x
			b.pos.y = b.pos.y + b.speed * b.vector.y
		else
			Lost = true
			love.event.quit()
		end
	end
end
function love.draw()
	-- Instructions
	local instructions = "F : turn | Q : quit"
	local debug = #Enemies
		.. " active enemies, they have "
		.. Enemies[1].remaining
		.. " bullets"
		.. "\n"
		.. "There is "
		.. #Bullets
		.. " bullets on the stack"
		.. "\n"
		.. table.concat(utils.map(Bullets, tostring), ", ")
	love.graphics.print(instructions .. "\n" .. debug .. "\n" .. tostring(Lost))

	-- Draw ship
	local width = Ship.sprite:getWidth()
	local height = Ship.sprite:getHeight()
	local orientation = math.pi / 2 * Ship.orientation
	love.graphics.draw(Ship.sprite, Width / 2, Height / 2, orientation, 1, 1, width / 2, height / 2)

	-- Draw all the bullets
	for _, b in ipairs(Bullets) do
		love.graphics.translate(Width / 2, Height / 2)
		love.graphics.setColor(b.color)
		love.graphics.circle("fill", b.pos.x, b.pos.y, 2)
		love.graphics.setColor(1, 1, 1)
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
