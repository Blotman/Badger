require("Platform/GameObject")
require("Platform/Physics/CapsulePhysicsObject")
require("Platform/StateMachine/CharacterStateMachine")

class("Character"):Extends( GameObject )

function Character:__init( params, world, physicsObject )
	
	self.width = params.width
	self.height = params.height

	--[[local halfWidth = self.width / 2
	local halfHeight = self.height / 2
	self.physicsCapsuleTopShape = love.physics.newCircleShape( self.physicsObject, 0, -halfHeight + halfWidth, halfWidth )
	self.physicsCapsuleMiddleShape = love.physics.newRectangleShape( self.physicsObject, 0, 0, self.width, self.height - self.width )
	self.physicsCapsuleBottomShape = love.physics.newCircleShape( self.physicsObject, 0, halfHeight - halfWidth, halfWidth )

	self.physicsCapsuleTopShape:setData( self )
	self.physicsCapsuleMiddleShape:setData( self )
	self.physicsCapsuleBottomShape:setData( self )

	self.physicsCapsuleTopShape:setCategory( World.physicsCategories.character1 )
	self.physicsCapsuleMiddleShape:setCategory( World.physicsCategories.character1 )
	self.physicsCapsuleBottomShape:setCategory( World.physicsCategories.character1 )

	self.physicsCapsuleTopShape:setFriction( 0 )
	self.physicsCapsuleMiddleShape:setFriction( 0 )
	self.physicsCapsuleBottomShape:setFriction( 0 )
--]]
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

	Character.super.__init( self, params, world )
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
	self.enterDuration = 2
	self.enterElapsed = 0
end

function Character:EntryUpdate( dt )
	self.enterElapsed = self.enterElapsed + dt
	if self.enterElapsed >= self.enterDuration then
		self.stateMachine:TriggerEvent("Next")
	end
end

function Character:EntryDraw()
	love.graphics.push()
	love.graphics.setColor( 128, 128, 128 )
	love.graphics.translate( self.physicsObject:GetX(), self.physicsObject:GetY() )
	self.physicsObject:Draw()
	love.graphics.pop()
end

function Character:ActiveUpdate( dt )
end

function Character:ActiveDraw()
	love.graphics.push()
	love.graphics.setColor( 255, 128, 128 )
	love.graphics.translate( self.physicsObject:GetX(), self.physicsObject:GetY() )
	self.physicsObject:Draw()
	love.graphics.pop()
end