require("Platform/GameObject")

class("Block"):Extends( GameObject )

function Block:__init( params, world, physicsObject )
	Block.super.__init( self, params, world )
	physicsObject = physicsObject or PhysicsObject:New(self)
	physicsObject.gravity = false
	self:SetPhysicsObject( physicsObject )
end

function Block:Draw()
	love.graphics.push()
	love.graphics.setColor( 128, 128, 128 )
	love.graphics.polygon( "fill", self.physicsObject:GetPoints() )
	love.graphics.pop()
end
