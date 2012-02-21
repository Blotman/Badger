require("Platform/Util")
require("Platform/Controller")
require("Platform/Mouse")
require("Platform/Editor")
require("Platform/World")
require("Platform/Physics/PhysicsObject")

require("Protagonist")
require("Antagonist")
require("Floater")
require("Block")

g_screenWidth = 1600
g_screenHeight = 900

function LoadTestWorld()
	local world = World:New( nil, 0, 0, g_screenWidth, g_screenHeight, 0, 500 )
	--for i=1,400 do
		--world:AddChild(Floater:New())
	--end

	Block:New( nil, world, g_screenWidth / 2, g_screenHeight / 2, 0, 0, 800, 500 )

	Block:New( nil, world, g_screenWidth / 2, 0, 0, 0, g_screenWidth, 1 )
	Block:New( nil, world, g_screenWidth / 2, g_screenHeight, 0, 0, g_screenWidth, 1 )
	Block:New( nil, world, 0, g_screenHeight / 2, 0, 0, 1, g_screenHeight )
	Block:New( nil, world, g_screenWidth, g_screenHeight / 2, 0, 0, 1, g_screenHeight )
	
	--world:AddChild( g_block )

	--[[g_antagonist = Antagonist:New()
	g_antagonist.physicsObject.position.x = g_screenWidth / 2
	g_antagonist.physicsObject.position.y = g_screenHeight / 2
	g_antagonist.physicsObject.velocity.y = 400
	g_antagonist.physicsObject.friction = 0

	world:AddChild(g_antagonist)--]]

	return world
end

function love.load(arg)
	love.graphics.setMode( g_screenWidth, g_screenHeight, false, 0 )
	------------------------------------------------------

	g_world = LoadTestWorld()
	--g_editor = Editor:New( nil, g_world, 0, 0, g_screenWidth, g_screenHeight )
	--g_world:Save("Wubba.txt")
	-- #####################################################

	--g_world = Class.InstantiateFromFile("Wubba.txt")
	
	-------------------------------------------------------
	--g_world:Save( "test.txt" )
	g_protagonist = Protagonist:New( nil, g_world )
	--g_world:AddChild( g_protagonist )

	g_framebuffer = love.graphics.newFramebuffer( g_screenWidth, g_screenHeight )
end

function love.keypressed(key, unicode)
print( "\"" .. key .. "\"", unicode  )
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
		--local selectedPhysicsObject = g_world.physicsObject:PointCast( x, y )
		--local selectedGameObject = selectedPhysicsObject and selectedPhysicsObject.gameObject
		--g_editor:SelectObject( selectedGameObject )
		--g_editor:HoldObject( selectedGameObject, x, y )
	end
end

function love.mousereleased( x, y, button )
	Mouse.ButtonState[button] = false
	if button == "l" then
		--g_editor:ReleaseObject( x, y )
	end
end

function love.update(dt)
	--g_protagonist.physicsObject.acceleration:set( (Controller.KeyState.right and 1.0 or 0.0) - (Controller.KeyState.left and 1.0 or 0.0),
	--											(Controller.KeyState.down and 1.0 or 0.0) - (Controller.KeyState.up and 1.0 or 0.0), 0.0 )
	--g_protagonist.physicsObject.acceleration:setLength(g_protagonist.physicsObject.friction * 2)

	--g_editor:Update(dt)
	local velocity = Vector:New( (Controller.KeyState.right and 1.0 or 0.0) - (Controller.KeyState.left and 1.0 or 0.0),
												(Controller.KeyState.down and 1.0 or 0.0) - (Controller.KeyState.up and 1.0 or 0.0), 0.0 )
	velocity:setLength(500)
	g_protagonist.physicsBody:setLinearVelocity( velocity.x, velocity.y )
	
	g_world:Update(dt)

end

function love.draw()
	love.graphics.setRenderTarget( g_framebuffer )
	g_world:Draw()
	--g_editor:Draw()

	love.graphics.setRenderTarget()

	love.graphics.setColor( 255, 255, 255 )
	love.graphics.draw(g_framebuffer, 0, 0, 0, 1, 1)
end