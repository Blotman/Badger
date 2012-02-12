require("Platform/GameObject")
require("Platform/Physics/WorldPhysicsObject")

class( "World" ):Extends( GameObject )

function World:__init( strName, xExtent1, yExtent1, xExtent2, yExtent2 )
	World.super.__init(self, strName, nil, WorldPhysicsObject:New(self, 8, xExtent1, yExtent1, xExtent2, yExtent2))
end

function World:AddChild( child )
	child:SetWorld( self )
	if child.physicsObject then
		self.physicsObject:AddChild( child.physicsObject )
	end
	World.super.AddChild( self, child )
end