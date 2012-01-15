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
		return xExtent1, yExtent1, xExtent2 / 2.0, yExtent2 / 2.0
	end,
	[2] = function(xExtent1, yExtent1, xExtent2, yExtent2)
		return xExtent2 / 2.0, yExtent1, xExtent2, yExtent2 / 2.0
	end,
	[3] = function(xExtent1, yExtent1, xExtent2, yExtent2)
		return xExtent2 / 2.0, yExtent2 / 2.0, xExtent2, yExtent2
	end,
	[4] = function(xExtent1, yExtent1, xExtent2, yExtent2)
		return xExtent1, yExtent2 / 2.0, xExtent2 / 2.0, yExtent2
	end,
}
	
function WorldPhysicsObject:PopulateTreeNode( node, depth, xExtent1, yExtent1, xExtent2, yExtent2 )
	for i, divideFunc in ipairs(WorldPhysicsObject.quadDivide) do
		local x1, y1, x2, y2 = divideFunc(xExtent1, yExtent1, xExtent2, yExtent2)
		local newNode = {
			xExtent1 = x1, yExtent1 = y1,
			xExtent2 = x2, yExtent2 = y2,
			objects = {},
		}
		node[i] = newNode
		if depth > 1 then
			self:PopulateTreeNode( newNode, depth - 1, x1, y1, x2, y2 )
		end
	end
end

function WorldPhysicsObject:VisitPoint( x, y )
	local visitedObjects = {}

	return visitedObjects
end

function WorldPhysicsObject:PointCast( x, y )
	local vistedObjects = self:VisitPoint( x, y )

	local foundObject = nil
	for object, _ in pairs( vistedObjects ) do
		if object.physicsObject and object.physicsObject:PointCast( x, y ) then
			foundObject = object
			break
		end
	end

	return foundObject
end
