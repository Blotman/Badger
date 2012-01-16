require("Platform/GameObject")
require("Platform/Physics/PhysicsObject")

class "Floater":Extends( GameObject )

function Floater:__init( strName )
	local vPos = Vector:New( math.random() * 1600, math.random() * 900, 0 )
	Floater.super.__init(self, strName, vPos, PhysicsObject:New(self))

	self.physicsObject.velocity:set( math.random() * 1000, 0, 0 )
end

function Floater:Update( dt )
	Floater.super.Update( self, dt )

	self.position.x = (self.position.x > 1600 and 0) or (self.position.x < 0 and 1600) or self.position.x
	self.position.y = (self.position.y > 900 and 0) or (self.position.y < 0 and 900) or self.position.y
end

function Floater:Draw()
	love.graphics.push()
	love.graphics.translate( self.position.x, self.position.y )
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.circle("fill", 0, 0, 2)
	love.graphics.pop()
end