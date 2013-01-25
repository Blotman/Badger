require("Platform/Physics/PhysicsObject")

class("CapsulePhysicsObject"):Extends( PhysicsObject )

function CapsulePhysicsObject:__init( gameObject )
	CapsulePhysicsObject.super.__init( self, gameObject )
	self.radius = gameObject.width / 2.0
	self.width = gameObject.width
	self.height = gameObject.height
	self.xExtent1 = -self.width / 2.0
	self.xExtent2 = self.width / 2.0
	self.yExtent1 = 0
	self.yExtent2 = -self.height - 2 * self.radius
end

function CapsulePhysicsObject:CollidedWith( testPhysicsObject )
	local rect_x1 = self.position.x + self.xExtent1
	local rect_y1 = self.position.y + self.yExtent1
	local rect_x2 = self.position.x + self.xExtent2
	local rect_y2 = self.position.y + self.yExtent2
	
	if testPhysicsObject:IsA( CirclePhysicsObject ) then
		local circle_x = testPhysicsObject.position.x
		local circle_y = testPhysicsObject.position.y
		local circle_r = testPhysicsObject.radius
		return RectCircleIntersect( rect_x1, rect_y1, rect_x2, rect_y2, circle_x, circle_y, circle_r )
	else
		local rect2_x1 = testPhysicsObject.position.x + testPhysicsObject.xExtent1
		local rect2_y1 = testPhysicsObject.position.y + testPhysicsObject.yExtent1
		local rect2_x2 = testPhysicsObject.position.x + testPhysicsObject.xExtent2
		local rect2_y2 = testPhysicsObject.position.y + testPhysicsObject.yExtent2

		return RectRectIntersect( rect_x1, rect_y1, rect_x2, rect_y2, rect2_x1, rect2_y1, rect2_x2, rect2_y2 )
	end
end

function CapsulePhysicsObject:Draw()
	local width = self.width
	local height = self.height
	local halfWidth = width / 2
	local halfHeight = height / 2

	local radius = self:GetRadius()
	local halfRadius = radius / 2

	love.graphics.circle("line", 0, -radius, radius, 20)
	love.graphics.polygon( "line", {	-halfWidth, -radius, 
										halfWidth, -radius, 
										halfWidth, -radius-height, 
										-halfWidth, -radius-height} )
	love.graphics.circle("line", 0, -radius-height, radius, 20)
end

function CapsulePhysicsObject:Update( dt )
	self.super.Update( self, dt )
end

function CapsulePhysicsObject:PointCast( x, y )
	return PointCircleIntersect( x, y, self.position.x, self.position.y, self.radius )
end

function CapsulePhysicsObject:GetRadius()
	return self.radius
end