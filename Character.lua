require("Platform/Body")
require("Platform/StateMachine/CharacterStateMachine")

class("Character"):Extends( Body )

function Character:__init( strName, world, x, y, width, height, mass )
	local vPos = Vector:New( x, y, 0 )
	Character.super.__init( self, strName, world, vPos, mass, 0 )
	self.width = width
	self.height = height

	local halfWidth = self.width / 2
	local halfHeight = self.height / 2
	self.physicsCapsuleTopShape = love.physics.newCircleShape( self.physicsBody, 0, -halfHeight + halfWidth, halfWidth )
	self.physicsCapsuleMiddleShape = love.physics.newRectangleShape( self.physicsBody, 0, 0, self.width, self.height - self.width )
	self.physicsCapsuleBottomShape = love.physics.newCircleShape( self.physicsBody, 0, halfHeight - halfWidth, halfWidth )

	self.physicsCapsuleTopShape:setData( self )
	self.physicsCapsuleMiddleShape:setData( self )
	self.physicsCapsuleBottomShape:setData( self )

	self.physicsCapsuleTopShape:setCategory( World.physicsCategories.character1 )
	self.physicsCapsuleMiddleShape:setCategory( World.physicsCategories.character1 )
	self.physicsCapsuleBottomShape:setCategory( World.physicsCategories.character1 )

	self.physicsCapsuleTopShape:setFriction( 0 )
	self.physicsCapsuleMiddleShape:setFriction( 0 )
	self.physicsCapsuleBottomShape:setFriction( 0 )

	self.stateMachine = CharacterStateMachine:New( self )
	self.stateMachine:SetStateCallbacks( "Entry",
		"EntryEnter",
		"EntryUpdate",
		"EntryDraw",
		nil )
	self.stateMachine:SetStateCallbacks( "Active",
		nil,
		"ActiveUpdate",
		"ActiveDraw",
		nil )
end

function Character:Update( dt )
	Character.super.Update( self, dt )
	self.stateMachine:Update( dt )

	--self.physicsObject.position.x = (self.physicsObject.position.x > self.world.physicsObject and 0) or (self.physicsObject.position.x < 0 and 1600) or self.physicsObject.position.x
	--self.physicsObject.position.y = (self.physicsObject.position.y > 900 and 0) or (self.physicsObject.position.y < 0 and 900) or self.physicsObject.position.y
end

function Character:Draw()
	self.stateMachine:Draw()
end

function Character:EntryEnter()
	self.enterRadius = 0
end

function Character:EntryUpdate( dt )
	self.enterRadius = self.enterRadius + 25.0 * dt
	if self.enterRadius > 25 then
		self.enterRadius = 25
		self.stateMachine:TriggerEvent("Next")
	end
end

function Character:EntryDraw()
	love.graphics.push()
	love.graphics.setColor( 128, 128, 128 )
	love.graphics.circle("fill", self.physicsBody:getX(), self.physicsBody:getY(), self.enterRadius, 20)
	love.graphics.pop()
end

function Character:ActiveUpdate( dt )
end

function Character:ActiveDraw()
	love.graphics.push()
	love.graphics.setColor( 255, 128, 128 )
	local halfWidth = self.width / 2
	local halfHeight = self.height / 2
	love.graphics.circle("fill", self.physicsBody:getX(), self.physicsBody:getY() - halfHeight + halfWidth, self.physicsCapsuleTopShape:getRadius(), 20)
	love.graphics.polygon( "fill", self.physicsCapsuleMiddleShape:getPoints() )
	love.graphics.circle("fill", self.physicsBody:getX(), self.physicsBody:getY() + halfHeight - halfWidth, self.physicsCapsuleBottomShape:getRadius(), 20)
	love.graphics.pop()
end