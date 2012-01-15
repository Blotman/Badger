require("Platform/GameObject")
require("Platform/Physics/PhysicsObject")

class("Pane"):Extends( GameObject )

function Pane:__init( strName, x, y, width, height )
	local vPos = Vector:New( x, y )
	Pane.super.__init(self, strName, vPos, PhysicsObject:New(self) )
	self.width = width
	self.height = height
	self.physicsObject.xExtent1 = 0
	self.physicsObject.yExtent1 = 0
	self.physicsObject.xExtent2 = width
	self.physicsObject.yExtent2 = height
end

function Pane:Update(dt)
	self.physicsObject.xExtent1 = 0
	self.physicsObject.yExtent1 = 0
	self.physicsObject.xExtent2 = self.width
	self.physicsObject.yExtent2 = self.height

	Pane.super.Update(self, dt)
end

function Pane:Draw()
	love.graphics.push()
	love.graphics.translate( self.position.x, self.position.y )
	love.graphics.setColor( 225, 225, 225 )
	love.graphics.polygon("fill", {	0, 0,
									self.width, 0,
									self.width, self.height,
									0, self.height})
	love.graphics.pop()
end
