require("Platform/GameObject")
require("Platform/Physics/PhysicsObject")

class("Pane"):Extends( GameObject )

function Pane:__init( strName, x, y, width, height )
	local vPos = Vector:New( x, y )
	Pane.super.__init(self, strName, vPos )
	self.width = width
	self.height = height
end

function Pane:Draw()
	local x1 = self.position.x
	local x2 = self.position.x + self.width
	local y1 = self.position.y
	local y2 = self.position.y + self.height
	love.graphics.polygon("fill", {	x1, y1,
									x2, y1,
									x2, y2,
									x1, y2})
end