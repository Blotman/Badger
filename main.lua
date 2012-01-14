require("Platform/Util")
require("Platform/Controller")
require("Platform/Mouse")
require("Platform/Physics/PhysicsObject")

require("Protagonist")
require("Antagonist")
require("Floater")

function love.load(arg)
	love.graphics.setMode( 1600, 900, false, 0 )
	------------------------------------------------------
	--[[
	g_world = GameObject:New()
	for i=1,20 do
		table.insert(g_world.children, Floater:New())
	end
	g_antagonist = Antagonist:New()
	g_antagonist.position.x = 800
	g_antagonist.position.y = 450
	g_antagonist.physicsObject.velocity.y = 400
	g_antagonist.physicsObject.friction = 0
	table.insert(g_world.children, g_antagonist)
	g_world:Save("Wubba.txt")
	--]]
	
	-- #####################################################
	
	g_world = Class.InstantiateFromFile("Wubba.txt")
	
	-------------------------------------------------------
	--g_world:Save( "test.txt" )
	g_protagonist = Protagonist:New()
	table.insert( g_world.children, g_protagonist )

	g_framebuffer = love.graphics.newFramebuffer( 1600, 900 )
end

function love.keypressed(key, unicode)
	local mapping = Controller.KeyMapping[key]
	if mapping then
		if Controller.KeyState[mapping] ~= nil then
			Controller.KeyState[mapping] = true
		end
	end
end

function love.keyreleased(key, unicode)
	local mapping = Controller.KeyMapping[key]
	if mapping then
		if Controller.KeyState[mapping] ~= nil then
			Controller.KeyState[mapping] = false
		end
	end
end

function love.mousepressed( x, y, button )
	Mouse.ButtonState[button] = true
	if button == "l" then
		local temp = g_world:ObjectsAtPoint( x, y )
		print( temp )
	end
end

function love.mousereleased( x, y, button )
	Mouse.ButtonState[button] = false
end

function love.update(dt)
	g_protagonist.physicsObject.acceleration:set( (Controller.KeyState.right and 1.0 or 0.0) - (Controller.KeyState.left and 1.0 or 0.0),
												(Controller.KeyState.down and 1.0 or 0.0) - (Controller.KeyState.up and 1.0 or 0.0), 0.0 )
	g_protagonist.physicsObject.acceleration:setLength(g_protagonist.physicsObject.friction * 2)
	g_world:Update(dt)
end

function love.draw()
	love.graphics.setRenderTarget( g_framebuffer )
	g_world:Draw()

	love.graphics.setRenderTarget()
	love.graphics.draw(g_framebuffer, 0, 0, 0, 1, 1)
end