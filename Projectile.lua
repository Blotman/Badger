require("Platform/Body")
require("Platform/StateMachine/CharacterStateMachine")

class("Projectile"):Extends( Body )

--Projectile.pool = {}

function Projectile:__init( strName, world, x, y )
	local vPos = Vector:New( x, y, 0 )
	Projectile.super.__init( self, strName, world, vPos, 5, 0 )
	self.physicsShape = love.physics.newCircleShape( self.physicsBody, 0, 0, .05 )
	self.physicsShape:setData( self )
	self.physicsShape:setSensor( true )
	self.physicsShape:setCategory( World.physicsCategories.projectile1 )
	self.physicsShape:setMask( World.physicsCategories.projectile1, World.physicsCategories.character1 )
	self.physicsShape:setFriction( 0 )

	self.lifeSeconds = 0
	self.maxLifeSeconds = 5.0
	self.originPosition = Vector:New( x, y, 0 )
end

function Projectile:Delete()
	self.physicsShape:destroy()
	Projectile.super.Delete( self )
end

function Projectile:DelayedDelete()
	self.physicsShape:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
	self.deleteFlag = true
end

function Projectile:Collided( otherObject, collisionInfo )
	self:DelayedDelete()
	--love.graphics.newParticleSystem
end

function Projectile:Update( dt )
	if self.deleteFlag then
		self:Delete()
	else
		self.lifeSeconds = self.lifeSeconds + dt
		if self.lifeSeconds > self.maxLifeSeconds then
			self:DelayedDelete()
		else
			Projectile.super.Update( self, dt )
		end
	end
end

function Projectile:Draw()
	local position = Vector:New( self.physicsBody:getPosition() )
	local velocity = Vector:New( self.physicsBody:getLinearVelocity() )
	local tail = Vector:New( velocity ):mul( -0.08 )
	tail:add(position)
	love.graphics.line( tail.x, tail.y, position.x, position.y )
end
