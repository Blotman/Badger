require("Platform/Util")
require("Platform/Physics/PhysicsObject")

class( "WorldPhysicsObject" ):Extends( PhysicsObject )

function WorldPhysicsObject:__init( gameObject, quadtreeDepth, xExtent1, yExtent1, xExtent2, yExtent2 )
	WorldPhysicsObject.super.__init( self, gameObject )

	self.quadTree = {}
	self.quadTreeDepth = quadtreeDepth
	self.xExtent1 = xExtent1
	self.xExtent2 = xExtent2
	self.yExtent1 = yExtent1
	self.yExtent2 = yExtent2

	self:PopulateTreeNode( self.quadTree, self.quadTreeDepth, xExtent1, yExtent1, xExtent2, yExtent2 )
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

function WorldPhysicsObject:VisitInQuadNode( visitedObjects, node, intersectFunc, engulfFunc )
	if intersectFunc( node ) then
		if #node > 0 and not engulfFunc( node ) then
			for i, childNode in ipairs(node) do
				self:VisitInQuadNode( visitedObjects, childNode, intersectFunc, engulfFunc )
			end
		else
			for object, _ in pairs(node.objects) do
				visitedObjects[object] = true
			end
		end
	end
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
	self:VisitInQuadNode( visitedObjects, self.quadTree, circleIntersect, circleEngulf )
	local foundObject = nil
	for object, _ in pairs( visitedObjects ) do
		if not ignoreTable[object] then
			local x1 = object.position.x + object.xExtent1
			local y1 = object.position.y + object.yExtent1
			local x2 = object.position.x + object.xExtent2
			local y2 = object.position.y + object.yExtent2
			if RectCircleIntersect( x1, y1, x2, y2, x, y, radius ) then
				foundObject = object
				break
			end
		end
	end

	return foundObject
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

function WorldPhysicsObject:AddObjectToQuadNode( node, physicsObject, x1, y1, x2, y2 )
	if RectRectIntersect( node.xExtent1, node.yExtent1, node.xExtent2, node.yExtent2, x1, y1, x2, y2 ) then
		node.objects[physicsObject] = true
		physicsObject.quadNodes[node] = true
		for i, childNode in ipairs(node) do
			self:AddObjectToQuadNode( childNode, physicsObject, x1, y1, x2, y2 )
		end
	end
end

function WorldPhysicsObject:RemoveObjectFromQuadNode( node, object )
	node.objects[object] = nil
end

function WorldPhysicsObject:ObjectMoved( physicsObject )
	local gameObjectPosition = physicsObject.position
	local x1 = gameObjectPosition.x + physicsObject.xExtent1
	local y1 = gameObjectPosition.y + physicsObject.yExtent1
	local x2 = gameObjectPosition.x + physicsObject.xExtent2
	local y2 = gameObjectPosition.y + physicsObject.yExtent2

	self:AddObjectToQuadNode( self.quadTree, physicsObject, x1, y1, x2, y2 )
end

function WorldPhysicsObject:Update( dt )
	self.super.Update( self, dt )

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
end
