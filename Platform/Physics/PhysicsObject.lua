require("Platform/Vector")
require("Platform/Util")

class "PhysicsObject"

function PhysicsObject:__init( gameObject )
	self.gameObject = gameObject
	self.position = Vector:New(0, 0, 0)
	self.lastPosition = nil
	self.velocity = Vector:New(0, 0, 0)
	self.acceleration = Vector:New(0, 0, 0)
	self.maxSpeed = -1
	self.friction = 0
	self.xExtent1 = -5
	self.xExtent2 = 5
	self.yExtent1 = -5
	self.yExtent2 = 5
	self.collision = true
end

function PhysicsObject:UpdatePosition( dt )
	self.velocity:add( self.acceleration:_mul( dt ) )
	local speed = self.velocity:len()
	if speed > 0 then
		local newSpeed = nil
		if self.friction > 0 then
			newSpeed = (speed < self.friction * dt and 0) or (speed - self.friction * dt)
		end

		if self.maxSpeed >= 0 then
			if speed > self.maxSpeed then
				newSpeed = self.maxSpeed
			end
		end

		if newSpeed ~= nil then
			self.velocity:mul( newSpeed / speed )
		end
	end

	local lastPosition = Vector:New( self.position )
	self.position:add( self.velocity:_mul( dt ) )

	if self.world and self.collision and (self.lastPosition == nil or self.lastPosition:notEquals(self.position)) then
		self.world:ObjectMoved( self )
	end
	self.lastPosition = lastPosition
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

		RectRectIntersect( rect_x1, rect_y1, rect_x2, rect_y2, rect2_x1, rect2_y1, rect2_x2, rect2_y2 )
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
	
	love.graphics.polygon("line", {	self.position.x + self.xExtent1, self.position.y + self.yExtent1,
									self.position.x + self.xExtent2, self.position.y + self.yExtent1,
									self.position.x + self.xExtent2, self.position.y + self.yExtent2,
									self.position.x + self.xExtent1, self.position.y + self.yExtent2})
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
