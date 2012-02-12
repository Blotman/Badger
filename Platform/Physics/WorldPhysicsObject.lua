require("Platform/Util")
require("Platform/Physics/PhysicsObject")

class( "WorldPhysicsObject" ):Extends( PhysicsObject )

function WorldPhysicsObject:__init( gameObject, quadtreeDepth, xExtent1, yExtent1, xExtent2, yExtent2 )
	WorldPhysicsObject.super.__init( self, gameObject )

	self.children = {}
	self.staticChildren = {}
	self.otherChildren = {}
	self.quadTree = {}
	self.quadTreeDepth = quadtreeDepth
	self.quadNodesOccupied = {}
	self.xExtent1 = xExtent1
	self.xExtent2 = xExtent2
	self.yExtent1 = yExtent1
	self.yExtent2 = yExtent2

	self:PopulateTreeNode( self.quadTree, self.quadTreeDepth, xExtent1, yExtent1, xExtent2, yExtent2 )
end

function WorldPhysicsObject:AddChild( child )
	child.world = self
	self.children[child] = true
	if child:IsA( StaticPhysicsObject ) then
		self.staticChildren[child] = true
	else
		self.otherChildren[child] = true
	end
	self:ObjectMoved( child )
end

WorldPhysicsObject.quadDivide = {
	[1] = function(xExtent1, yExtent1, xExtent2, yExtent2)
		return xExtent1, yExtent1, (xExtent1 + xExtent2) / 2.0, (yExtent1 + yExtent2) / 2.0
	end,
	[2] = function(xExtent1, yExtent1, xExtent2, yExtent2)
		return (xExtent1 + xExtent2) / 2.0, yExtent1, xExtent2, (yExtent1 + yExtent2) / 2.0
	end,
	[3] = function(xExtent1, yExtent1, xExtent2, yExtent2)
		return (xExtent1 + xExtent2) / 2.0, (yExtent1 + yExtent2) / 2.0, xExtent2, yExtent2
	end,
	[4] = function(xExtent1, yExtent1, xExtent2, yExtent2)
		return xExtent1, (yExtent1 + yExtent2) / 2.0, (xExtent1 + xExtent2) / 2.0, yExtent2
	end,
}
	
function WorldPhysicsObject:PopulateTreeNode( node, depth, xExtent1, yExtent1, xExtent2, yExtent2 )
	node.xExtent1 = xExtent1
	node.yExtent1 = yExtent1
	node.xExtent2 = xExtent2
	node.yExtent2 = yExtent2
	node.objects = {}

	if depth > 1 then
		for i, divideFunc in ipairs(WorldPhysicsObject.quadDivide) do
			local x1, y1, x2, y2 = divideFunc(xExtent1, yExtent1, xExtent2, yExtent2)
			local newNode = {}
			node[i] = newNode
			self:PopulateTreeNode( newNode, depth - 1, x1, y1, x2, y2 )
		end
	end
end

function WorldPhysicsObject:QuadNodesInArea( nodesTable, node, intersectFunc, engulfFunc )
	if intersectFunc( node ) then
		if #node > 0 and not engulfFunc( node ) then
			for i, childNode in ipairs(node) do
				self:QuadNodesInArea( nodesTable, childNode, intersectFunc, engulfFunc )
			end
		else
			nodesTable[node] = true
		end
	end
end

function WorldPhysicsObject:QuadNodesInRadius( x, y, radius )
	local quadNodes = {}
	local function circleIntersect( node )
		return RectCircleIntersect( node.xExtent1, node.yExtent1, node.xExtent2, node.yExtent2, x, y, radius )
	end

	local function circleEngulf( node )
		local left = x - radius
		local right = x + radius
		local top = y - radius
		local bottom = y + radius

		return left <= node.xExtent1 and top <= node.yExtent1 and right >= node.xExtent2 and bottom >= node.yExtent2
	end

	self:QuadNodesInArea( quadNodes, self.quadTree, circleIntersect, circleEngulf )
	
	return quadNodes
end

function WorldPhysicsObject:VisitInQuadNode( visitedObjects, node, ignoreTable, intersectFunc, engulfFunc )
	if intersectFunc( node ) then
		if #node > 0 and not engulfFunc( node ) then
			for i, childNode in ipairs(node) do
				self:VisitInQuadNode( visitedObjects, childNode, ignoreTable, intersectFunc, engulfFunc )
			end
		else
			for object, _ in pairs(node.objects) do
				if not ignoreTable or not ignoreTable[object] then
					visitedObjects[object] = true
				end
			end
		end
	end
end

function WorldPhysicsObject:VisitRect( x1, y1, x2, y2, ignoreTable )
	local function rectIntersect( node )
		return RectRectIntersect( x1, y1, x2, y2, node.xExtent1, node.yExtent1, node.xExtent2, node.yExtent2 )
	end

	local function rectEngulf( node )
		return x1 <= node.xExtent1 and y1 <= node.yExtent1 and x2 >= node.xExtent2 and y2 >= node.yExtent2
	end

	local visitedObjects = {}
	self:VisitInQuadNode( visitedObjects, self.quadTree, ignoreTable, rectIntersect, rectEngulf )

	return visitedObjects
end

function WorldPhysicsObject:VisitRadius( x, y, radius, ignoreTable )
	local function circleIntersect( node )
		return RectCircleIntersect( node.xExtent1, node.yExtent1, node.xExtent2, node.yExtent2, x, y, radius )
	end
	
	local function circleEngulf( node )
		local left = x - radius
		local right = x + radius
		local top = y - radius
		local bottom = y + radius

		return left <= node.xExtent1 and top <= node.yExtent1 and right >= node.xExtent2 and bottom >= node.yExtent2
	end

	local visitedObjects = {}
	self:VisitInQuadNode( visitedObjects, self.quadTree, ignoreTable, circleIntersect, circleEngulf )
	local foundObject = nil
	for object, _ in pairs( visitedObjects ) do
		local x1 = object.position.x + object.xExtent1
		local y1 = object.position.y + object.yExtent1
		local x2 = object.position.x + object.xExtent2
		local y2 = object.position.y + object.yExtent2
		if not RectCircleIntersect( x1, y1, x2, y2, x, y, radius ) then
			visitedObjects[object] = nil
		end
	end

	return visitedObjects
end

function WorldPhysicsObject:PointCast( x, y )
	local function pointIntersect( node )
		return PointRectIntersect( x, y, node.xExtent1, node.yExtent1, node.xExtent2, node.yExtent2 )
	end

	local visitedObjects = {}
	self:VisitInQuadNode( visitedObjects, self.quadTree, pointIntersect, function() return false end )

	local foundObject = nil
	for object, _ in pairs( visitedObjects ) do
		if object:PointCast( x, y ) then
			foundObject = object
			break
		end
	end

	return foundObject
end

function WorldPhysicsObject:AddObjectToQuadNode( node, physicsObject, x1, y1, x2, y2, nodesOccupied )
	if RectRectIntersect( node.xExtent1, node.yExtent1, node.xExtent2, node.yExtent2, x1, y1, x2, y2 ) then
		node.objects[physicsObject] = true
		nodesOccupied[node] = true
		for i, childNode in ipairs(node) do
			self:AddObjectToQuadNode( childNode, physicsObject, x1, y1, x2, y2, nodesOccupied )
		end
	end
end

function WorldPhysicsObject:RemoveObjectFromQuadNode( node, object )
	node.objects[object] = nil
end

function WorldPhysicsObject:ObjectMoved( physicsObject )
	local physicsObjectPosition = physicsObject.position
	local x1 = physicsObjectPosition.x + physicsObject.xExtent1
	local y1 = physicsObjectPosition.y + physicsObject.yExtent1
	local x2 = physicsObjectPosition.x + physicsObject.xExtent2
	local y2 = physicsObjectPosition.y + physicsObject.yExtent2

	if self.containCollisionObjects and physicsObject.collision then
		physicsObjectPosition.x = x1 < self.quadTree.xExtent1 and physicsObjectPosition.x + ( self.quadTree.xExtent1 - x1 )
			or x2 > self.quadTree.xExtent2 and physicsObjectPosition.x + ( self.quadTree.xExtent2 - x2 )
			or physicsObjectPosition.x

		physicsObjectPosition.y = y1 < self.quadTree.yExtent1 and physicsObjectPosition.y + ( self.quadTree.yExtent1 - y1 )
			or y2 > self.quadTree.yExtent2 and physicsObjectPosition.y + ( self.quadTree.yExtent2 - y2 )
			or physicsObjectPosition.y
	end

	local nodesOccupied = {}
	self:AddObjectToQuadNode( self.quadTree, physicsObject, x1, y1, x2, y2, nodesOccupied )

	local lastNodesOccupied = self.quadNodesOccupied[physicsObject]
	if lastNodesOccupied then
		for node, _ in pairs( lastNodesOccupied ) do
			if nodesOccupied[node] == nil then
				self:RemoveObjectFromQuadNode( node, physicsObject )
			end
		end
	end
	self.quadNodesOccupied[physicsObject] = nodesOccupied
end

function WorldPhysicsObject:Update( dt )
	for child, _ in pairs( self.children ) do
		child:UpdatePosition( dt )
	end

	local appliedCollisionTable = {}
	for child, _ in pairs( self.children ) do
		appliedCollisionTable[child] = child:GetCollisionInfo( dt )
	end

	for child, collisionInfo in pairs(appliedCollisionTable) do
		if collisionInfo.position then
			child.position:set(collisionInfo.position)
		end
	end
	--[[
	for staticObject, _ in pairs( self.staticChildren ) do
		local rect_x1 = staticObject.position.x + staticObject.xExtent1
		local rect_y1 = staticObject.position.y + staticObject.yExtent1
		local rect_x2 = staticObject.position.x + staticObject.xExtent2
		local rect_y2 = staticObject.position.y + staticObject.yExtent2

		local ignoreTable = {}
		ignoreTable[staticObject] = true

		local visitedObject = self:VisitRect( rect_x1, rect_y1, rect_x2, rect_y2, ignoreTable )
		for visitedObject, _ in pairs( visitedObject ) do
			--visitedObject.position:set( 0, 0 )
		end
	end
	--]]
	--[[
	local rect_x1 = g_antagonist.position.x + g_antagonist.physicsObject.xExtent1
	local rect_y1 = g_antagonist.position.y + g_antagonist.physicsObject.yExtent1
	local rect_x2 = g_antagonist.position.x + g_antagonist.physicsObject.xExtent2
	local rect_y2 = g_antagonist.position.y + g_antagonist.physicsObject.yExtent2
	local circle_x = g_protagonist.position.x
	local circle_y = g_protagonist.position.y
	local circle_r = g_protagonist.physicsObject.radius
	
	local ignoreTable = {}
	ignoreTable[g_protagonist.physicsObject] = true
	local foundObject = self:VisitRadius( circle_x, circle_y, circle_r, ignoreTable )
	if foundObject == g_antagonist.physicsObject then
		local speed = foundObject.velocity:len()
		local displacement = g_antagonist.position:_sub(g_protagonist.position):setLength(speed)
		foundObject.velocity:set(displacement)
	end
	--]]
end
