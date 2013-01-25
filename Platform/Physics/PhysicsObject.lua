require("Platform/Vector")
require("Platform/Util")

class("PhysicsObject")

function PhysicsObject:__init( gameObject )
	self.gameObject = gameObject
	self.position = Vector:New( gameObject.position.x, gameObject.position.y, gameObject.position.z)
	self.lastPosition = nil
	self.velocity = Vector:New(0, 0, 0)
	self.acceleration = Vector:New(0, 0, 0)
	self.maxSpeed = -1
	self.friction = 0
	self.xExtent1 = -5
	self.xExtent2 = 5
	self.yExtent1 = -5
	self.yExtent2 = 5
	self.gravity = true
	self.collision = true
end

function PhysicsObject:VisitWorld()
	local visitedObject = nil
	if self.world then
		local rect_x1 = self.position.x + self.xExtent1
		local rect_y1 = self.position.y + self.yExtent1
		local rect_x2 = self.position.x + self.xExtent2
		local rect_y2 = self.position.y + self.yExtent2
		
		local ignoreTable = {}
		ignoreTable[self] = true

		visitedObject = self.world:VisitRect( rect_x1, rect_y1, rect_x2, rect_y2, ignoreTable )
	end
	return visitedObject
end

function PhysicsObject:CollidedWith( testPhysicsObject )
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

function PhysicsObject:GetAppliedCollision( dt )
	local appliedCollision = nil

	local visitedObjects = self:VisitWorld()
	if visitedObjects then
		local collidedDt = dt
		-- Determine which of the visited objects actually collided
		-- For dynamic to static interaction
		--   Get tangent vector of collision point
		--   Move position of dynamic object perpendicular away from tangent until not collided
		for visitedObject, _ in pairs(visitedObjects) do
			if self:CollidedWith( visitedObject ) then
				local positionAtTestDt = Vector:New( visitedObject.positions )
				appliedCollision = { position = Vector:New( self.lastPosition  ) }
			end
		end
	end

	return appliedCollision
end

function PhysicsObject:DrawQuadNodes()
	local nodesOccupied = self.world.quadNodesOccupied[self]
	for node, _ in pairs( nodesOccupied ) do
		love.graphics.polygon("line", {	node.xExtent1, node.yExtent1,
										node.xExtent2, node.yExtent1,
										node.xExtent2, node.yExtent2,
										node.xExtent1, node.yExtent2})
	end
	
	love.graphics.polygon("line", self:GetPoints() )
end

function PhysicsObject:Serialize(depth)
	local serialized = {}
	table.insert( serialized, "{" )
	SerializeHelper( self, serialized, {"className", "velocity", "acceleration", "maxSpeed", "friction"}, depth+1)
	table.insert( serialized, "\n" .. Tab(depth) .. "}" )

	return table.concat(serialized)
end

function PhysicsObject:GetExtents()
	local gameObjectPosition = self.position
	return gameObjectPosition.x + self.xExtent1, gameObjectPosition.y + self.yExtent1, gameObjectPosition.x + self.xExtent2, gameObjectPosition.y + self.yExtent2
end

function PhysicsObject:PointCast( x, y )
	return PointRectIntersect( x, y, self:GetExtents() )
end

function PhysicsObject:GetPoints()
	return {	self.position.x + self.xExtent1, self.position.y + self.yExtent1,
									self.position.x + self.xExtent2, self.position.y + self.yExtent1,
									self.position.x + self.xExtent2, self.position.y + self.yExtent2,
									self.position.x + self.xExtent1, self.position.y + self.yExtent2}
end

function PhysicsObject:GetX()
	return self.position.x
end

function PhysicsObject:GetY()
	return self.position.y
end

function PhysicsObject:ApplyForce( forceVector )
	self.acceleration:add( forceVector )
end

function PhysicsObject:UpdateVelocity( dt )
	if self.world ~= nil and self.gravity then
		self.velocity:add( self.world.gravity:_mul( dt ) )
	end

	self.velocity:add( self.acceleration:_mul( dt ) )
	
	local speed2 = self.velocity:len2()
	if speed2 > 0 and self.maxSpeed >= 0 then
		local maxSpeed2 = self.maxSpeed * self.maxSpeed
		if speed2 > maxSpeed2 then
			local speed = math.sqrt(speed2)
			self.velocity:mul( self.maxSpeed / speed )
		end
	end
end

function PhysicsObject:UpdatePosition( dt )
	local lastPosition = Vector:New( self.position )
	self.position:add( self.velocity:_mul( dt ) )

	if self.world and self.collision and (self.lastPosition == nil or self.lastPosition:notEquals(self.position)) then
		self.world:ObjectMoved( self )
	end

	self.lastPosition = lastPosition
end