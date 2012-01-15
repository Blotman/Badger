require("Platform/GameObject")
require("Platform/Physics/CirclePhysicsObject")

class("Protagonist"):Extends( GameObject )

function Protagonist:__init( strName )
	local vPos = Vector:New( math.random() * 1600, math.random() * 900, 0 )
	Protagonist.super.__init(self, strName, vPos, CirclePhysicsObject:New(self, 50))

	self.physicsObject.maxSpeed = 400
	self.physicsObject.friction = 2000
	self.physicsObject.xExtent1 = -self.physicsObject.radius
	self.physicsObject.xExtent2 = self.physicsObject.radius
	self.physicsObject.yExtent1 = -self.physicsObject.radius
	self.physicsObject.yExtent2 = self.physicsObject.radius
end

function Protagonist:Update( dt )
	Protagonist.super.Update( self, dt )

	self.position.x = (self.position.x > 1600 and 0) or (self.position.x < 0 and 1600) or self.position.x
	self.position.y = (self.position.y > 900 and 0) or (self.position.y < 0 and 900) or self.position.y
end

function Protagonist:Draw()
	love.graphics.push()
	love.graphics.translate( self.position.x, self.position.y )
	love.graphics.setColor( 255, 128, 128 )
	love.graphics.circle("fill", 0, 0, self.physicsObject.radius)
	love.graphics.pop()
end
