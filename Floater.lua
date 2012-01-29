require("Platform/GameObject")
require("Platform/Physics/CirclePhysicsObject")

class "Floater":Extends( GameObject )

function Floater:__init( strName )
	local vPos = Vector:New( math.random() * 1600, math.random() * 900, 0 )
	Floater.super.__init(self, strName, vPos, CirclePhysicsObject:New(self, 5))

	self.physicsObject.velocity:set( math.random() * 1000, 0, 0 )
	self.physicsObject.collision = false
end

function Floater:Update( dt )
	Floater.super.Update( self, dt )

	self.physicsObject.position.x = (self.physicsObject.position.x > 1600 and 0) or (self.physicsObject.position.x < 0 and 1600) or self.physicsObject.position.x
	self.physicsObject.position.y = (self.physicsObject.position.y > 900 and 0) or (self.physicsObject.position.y < 0 and 900) or self.physicsObject.position.y
	self.position:set(self.physicsObject.position)
end

function Floater:Draw()
	love.graphics.push()
	love.graphics.translate( self.position.x, self.position.y )
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.circle("fill", 0, 0, self.physicsObject.radius)
	love.graphics.pop()
end