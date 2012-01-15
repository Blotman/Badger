require("Platform/Physics/PhysicsObject")

class("CirclePhysicsObject"):Extends( PhysicsObject )

function CirclePhysicsObject:__init( gameObject, radius )
	CirclePhysicsObject.super.__init( self, gameObject )
	self.radius = radius
end

function CirclePhysicsObject:PointCast( x, y )
	return PointCircleIntersect( x, y, self.gameObject.position.x, self.gameObject.position.y, self.radius )
end
