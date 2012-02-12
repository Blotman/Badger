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

function PhysicsObject:GetCollisionInfo( dt )
	local collisionInfo = nil

	local collidedObjects = self:VisitWorld()
	if collidedObjects then
		local collidedDt = dt
		for collidedObject, _ in pairs(collidedObjects) do
			local positionAtTestDt = Vector:New( collidedObject.positions )
			collisionInfo = { position = Vector:New( self.lastPosition  ) }
		end
	end

	return collisionInfo
end

function PhysicsObject:DrawQuadNodes()
	local nodesOccupied = self.world.quadNodesOccupied[self]
	for node, _ in pairs( self.quadNodes ) do
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
