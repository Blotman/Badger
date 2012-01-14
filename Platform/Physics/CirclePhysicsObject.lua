require("Platform/Physics/PhysicsObject")

class("CirclePhysicsObject"):Extends( PhysicsObject )

function CirclePhysicsObject:__init( gameObject, radius )
	CirclePhysicsObject.super.__init( self, gameObject )
	self.radius = radius
end
