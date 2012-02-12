require("Platform/Physics/PhysicsObject")

class("StaticPhysicsObject"):Extends( PhysicsObject )

function StaticPhysicsObject:__init( gameObject )
	StaticPhysicsObject.super.__init( self, gameObject )
end
