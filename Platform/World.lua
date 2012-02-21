require("Platform/GameObject")
require("Platform/Physics/WorldPhysicsObject")

class( "World" )

function World:__init( strName, xExtent1, yExtent1, xExtent2, yExtent2, xGravity, yGravity )
	self.name = strName
	self.physicsWorld = love.physics.newWorld( xExtent1, yExtent1, xExtent2, yExtent2, xGravity or 0, yGravity or 0, true )
	self.physicsWorld:setCallbacks( World.ObjectsCollided, World.ObjectsTouching, World.ObjectsUncollided, result)
	self.children = {}
end

function World:AddChild( child )
	table.insert(self.children, child)
end

function World:Update( dt )
	self.physicsWorld:update( dt )

	for _, child in ipairs(self.children) do
		child:Update(dt)
	end
end

function World:Draw()
	for _, child in ipairs(self.children) do
		child:Draw()
	end
end

function World.ObjectsCollided(a, b, coll)
end

function persist(a, b, coll)
    
end

function World.ObjectsUncollided(a, b, coll)
end

function result(a, b, coll)
end