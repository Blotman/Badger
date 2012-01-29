require("Platform/Physics/PhysicsObject")

class("CirclePhysicsObject"):Extends( PhysicsObject )

function CirclePhysicsObject:__init( gameObject, radius )
	CirclePhysicsObject.super.__init( self, gameObject )
	self.radius = radius
	self.xExtent1 = -radius
	self.xExtent2 = radius
	self.yExtent1 = -radius
	self.yExtent2 = radius
end

function CirclePhysicsObject:Update( dt )
	self.super.Update( self, dt )

	--[[local worldPhysicsObject = self.gameObject and self.gameObject.world and self.gameObject.world.physicsObject
	if worldPhysicsObject then
		worldPhysicsObject:VisitRadius( self.position.x, self.position.y, self.radius )
	end--]]
end

function CirclePhysicsObject:PointCast( x, y )
	return PointCircleIntersect( x, y, self.position.x, self.position.y, self.radius )
end
