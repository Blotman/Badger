require("Platform/GameObject")
require("Platform/Physics/CirclePhysicsObject")
require("Platform/StateMachine/CharacterStateMachine")

class("Protagonist"):Extends( GameObject )

function Protagonist:__init( strName )
	local vPos = Vector:New( math.random() * 1600, math.random() * 900, 0 )
	Protagonist.super.__init(self, strName, vPos, CirclePhysicsObject:New(self, 50))

	self.physicsObject.maxSpeed = 400
	self.physicsObject.friction = 2000
	
	self.stateMachine = CharacterStateMachine:New( self )
	self.stateMachine:SetUpdateCallback( "Entry", Protagonist.EntryUpdate )
	self.stateMachine:SetDrawCallback( "Entry", Protagonist.EntryDraw )
end

function Protagonist:Update( dt )
	Protagonist.super.Update( self, dt )
	self.stateMachine:Update( dt )

	--self.physicsObject.position.x = (self.physicsObject.position.x > self.world.physicsObject and 0) or (self.physicsObject.position.x < 0 and 1600) or self.physicsObject.position.x
	--self.physicsObject.position.y = (self.physicsObject.position.y > 900 and 0) or (self.physicsObject.position.y < 0 and 900) or self.physicsObject.position.y
end

function Protagonist:EntryUpdate( dt )
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

function Protagonist:EntryDraw()
	love.graphics.push()
	love.graphics.translate( self.position.x, self.position.y )
	love.graphics.setColor( 255, 128, 128 )
	love.graphics.circle("fill", 0, 0, self.physicsObject.radius)
	love.graphics.pop()
end