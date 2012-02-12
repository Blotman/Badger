require("Platform/GameObject")
require("Platform/Physics/StaticPhysicsObject")

class("Block"):Extends( GameObject )

function Block:__init( strName, x, y, width, height )
	local vPos = Vector:New( x, y )
	Block.super.__init(self, strName, vPos, StaticPhysicsObject:New(self))

	self.physicsObject.xExtent1 = -width / 2
	self.physicsObject.xExtent2 = width / 2
	self.physicsObject.yExtent1 = -height / 2
	self.physicsObject.yExtent2 = height / 2
end

function Block:Update( dt )
	Block.super.Update( self, dt )
end

function Block:Draw()
	love.graphics.push()
	love.graphics.translate( self.position.x, self.position.y )
	love.graphics.setColor( 128, 128, 128 )
	love.graphics.rectangle( "fill", self.physicsObject.xExtent1, self.physicsObject.yExtent1, self.physicsObject.xExtent2, self.physicsObject.yExtent2 )
	--love.graphics.circle("fill", 0, 0, self.enterRadius)
	love.graphics.pop()
end
