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

function WorldPhysicsObject:VisitPointInQuadNode( node, x, y )
	local visitedObjects = nil
	if PointRectIntersect( x, y, node.xExtent1, node.yExtent1, node.xExtent2, node.yExtent2 ) then
		if #node > 0 then
			for i, childNode in ipairs(node) do
				visitedObjects = self:VisitPointInQuadNode( childNode, x, y ) or visitedObjects
			end
		else
			visitedObjects = node.objects
		end
	end
	return visitedObjects
end

function WorldPhysicsObject:PointCast( x, y )
	local vistedObjects = self:VisitPointInQuadNode( self.quadTree, x, y )

	local foundObject = nil
	for object, _ in pairs( vistedObjects ) do
	print( "test 1" )
		if object:PointCast( x, y ) then
		print( "test 2" )
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
	local gameObjectPosition = physicsObject.gameObject.position
	local x1 = gameObjectPosition.x + physicsObject.xExtent1
	local y1 = gameObjectPosition.y + physicsObject.yExtent1
	local x2 = gameObjectPosition.x + physicsObject.xExtent2
	local y2 = gameObjectPosition.y + physicsObject.yExtent2

	self:AddObjectToQuadNode( self.quadTree, physicsObject, x1, y1, x2, y2 )
end
