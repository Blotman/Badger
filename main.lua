require("Platform/Util")
require("Platform/Controller")
require("Platform/Mouse")
require("Platform/Editor")
require("Platform/World")
require("Platform/Physics/PhysicsObject")
require("Platform/Physics/WorldPhysicsObject")

require("Protagonist")
require("Antagonist")
require("Floater")
require("Block")
require("Projectile")

g_screenWidth = 1600
g_screenHeight = 900

function LoadTestWorld()
	local world = World:New( {strName = "World_0",
		xExtent1 = 0,
		yExtent1 = 0,
		xExtent2 = g_screenWidth,
		yExtent2 = g_screenHeight,
		xGravity = nil,
		yGravity = 1000} )

	local worldPhysicsObject = WorldPhysicsObject:New(8, -3000, -2000, 3000, 2000)
	world:SetPhysicsObject( worldPhysicsObject )
	--for i=1,400 do
		--world:AddChild(Floater:New())
	--end

	Block:New( { 	strName = "Block_0",
					x = g_screenWidth / 2,
					y = g_screenHeight * 3 / 4,
					mass = 0,
					inertia = 0,
					friction = 0,
					width = 800,
					height = 500 }, world )
--[[
	Block:New(	{ 	strName = "Block_1",
					x = g_screenWidth / 2,
					y = 0,
					mass = 0,
					inertia = 0,
					friction = 0,
					width = g_screenWidth,
					height = 1 }, world )

	Block:New(	{ 	strName = "Block_2",
					x = g_screenWidth / 2,
					y = g_screenHeight,
					mass = 0,
					inertia = 0,
					friction = 0,
					width = g_screenWidth,
					height = 1 }, world )

	Block:New(	{ 	strName = "Block_3",
					x = 0,
					y = g_screenHeight / 2,
					mass = 0,
					inertia = 0,
					friction = 0,
					width = 1,
					height = g_screenHeight }, world )

	Block:New(	{ 	strName = "Block_4",
					x = g_screenWidth,
					y = g_screenHeight / 2,
					mass = 0,
					inertia = 0,
					friction = 0,
					width = 1,
					height = g_screenHeight }, world )
--]]
	--world:AddChild( g_block )
	--[[g_antagonist = Antagonist:New(	{ 	strName = "Antagonist_0",
										x = 200,
										y = 800 }, world )--]]

	g_protagonist = Protagonist:New( { 	strName = "Protagonist_0",
										x = 800,
										y = 500 }, world )
	g_protagonist:SetPhysicsObject( CapsulePhysicsObject:New( g_protagonist ) )

	return world
end

function love.load(arg)
	love.graphics.setMode( g_screenWidth, g_screenHeight, false, 0 )
	------------------------------------------------------

	g_world = LoadTestWorld()
	--g_world = LoadFromXMLFile("Wubba.txt")
	--[[g_editor = Editor:New( {	xExtent1 = 0,
								yExtent1 = 0,
								xExtent2 = g_screenWidth,
								yExtent2 = g_screenHeight }, g_world )--]]
	--g_world:Save("Wubba.txt")
	-- #####################################################
	
	-------------------------------------------------------

	g_canvas = love.graphics.newCanvas( g_screenWidth, g_screenHeight )
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
	g_world:Update(dt)
end

function love.draw()
	love.graphics.setCanvas( g_canvas )
	--love.graphics.setColor( 255, 255, 255 )
	love.graphics.clear()
	g_world.camera.position:set( g_screenWidth / 2.0, g_screenHeight / 2.0 )

	g_world:Draw()
	g_protagonist.physicsObject:DrawQuadNodes()

	love.graphics.setCanvas()
	--g_editor:Draw()

	
	love.graphics.draw(g_canvas, 0, 0, 0, 1, 1)
end