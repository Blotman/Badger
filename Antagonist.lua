require("Platform/GameObject")
require("Platform/Physics/PhysicsObject")

class("Antagonist"):Extends( GameObject )

function Antagonist:__init( strName )
	local vPos = Vector:New( math.random() * 1600, math.random() * 900, 0 )
	Antagonist.super.__init(self, strName, vPos, CirclePhysicsObject:New(self, 50))

	self.physicsObject.maxSpeed = 400
	self.physicsObject.friction = 2000
end

function Antagonist:Update( dt )
	Antagonist.super.Update( self, dt )

	self.position.x = (self.position.x > 1600 and 0) or (self.position.x < 0 and 1600) or self.position.x
	self.position.y = (self.position.y > 900 and 0) or (self.position.y < 0 and 900) or self.position.y
end

function Antagonist:Draw()
	love.graphics.push()
	love.graphics.translate( self.position.x, self.position.y )
	love.graphics.setColor( 0, 255, 255 )
	love.graphics.circle("fill", 0, 0, self.physicsObject.radius)
	love.graphics.pop()
end
