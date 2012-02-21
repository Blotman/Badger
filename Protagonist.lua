require("Platform/Body")
require("Platform/StateMachine/CharacterStateMachine")

class("Protagonist"):Extends( Body )

function Protagonist:__init( strName, world )
	local vPos = Vector:New( 50, 50, 0 )
	Protagonist.super.__init( self, strName, world, vPos, 5, 0 )
	self.physicsShape = love.physics.newCircleShape( self.physicsBody, 0, 0, 50 )
	self.physicsShape:setFriction( 0 )

	--self.physicsObject.maxSpeed = 400
	--self.physicsObject.friction = 2000
	
	self.stateMachine = CharacterStateMachine:New( self )
	self.stateMachine:SetStateCallbacks( "Entry",
		Protagonist.EntryEnter,
		Protagonist.EntryUpdate,
		Protagonist.EntryDraw,
		nil )
	self.stateMachine:SetStateCallbacks( "Active",
		nil,
		Protagonist.ActiveUpdate,
		Protagonist.ActiveDraw,
		nil )
end

function Protagonist:Update( dt )
	Protagonist.super.Update( self, dt )
	self.stateMachine:Update( dt )

	--self.physicsObject.position.x = (self.physicsObject.position.x > self.world.physicsObject and 0) or (self.physicsObject.position.x < 0 and 1600) or self.physicsObject.position.x
	--self.physicsObject.position.y = (self.physicsObject.position.y > 900 and 0) or (self.physicsObject.position.y < 0 and 900) or self.physicsObject.position.y
end

function Protagonist:Draw()
	self.stateMachine:Draw()
--[[	
	local quadNodes = self.world.physicsObject:QuadNodesInRadius( self.position.x, self.position.y, self.physicsObject.radius )
	for node, _ in pairs( quadNodes ) do
		love.graphics.polygon("line", {	node.xExtent1, node.yExtent1,
										node.xExtent2, node.yExtent1,
										node.xExtent2, node.yExtent2,
										node.xExtent1, node.yExtent2})
	end--]]
end

function Protagonist:EntryEnter()
	self.enterRadius = 0
end

function Protagonist:EntryUpdate( dt )
	self.enterRadius = self.enterRadius + 25.0 * dt
	local physicsRadius = self.physicsShape:getRadius()
	if self.enterRadius > physicsRadius then
		self.enterRadius = physicsRadius
		self.stateMachine:TriggerEvent("Next")
	end
end

function Protagonist:EntryDraw()
	love.graphics.push()
	love.graphics.setColor( 128, 128, 128 )
	love.graphics.circle("fill", self.physicsBody:getX(), self.physicsBody:getY(), self.enterRadius, 20)
	love.graphics.pop()
end

function Protagonist:ActiveUpdate( dt )
end

function Protagonist:ActiveDraw()
	love.graphics.push()
	love.graphics.setColor( 255, 128, 128 )
	love.graphics.circle("fill", self.physicsBody:getX(), self.physicsBody:getY(), self.physicsShape:getRadius(), 20)
	love.graphics.pop()
end