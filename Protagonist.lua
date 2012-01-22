require("Platform/GameObject")
require("Platform/Physics/CirclePhysicsObject")

class("Protagonist"):Extends( GameObject )

function Protagonist:__init( strName )
	local vPos = Vector:New( math.random() * 1600, math.random() * 900, 0 )
	Protagonist.super.__init(self, strName, vPos, CirclePhysicsObject:New(self, 50))

	self.physicsObject.maxSpeed = 400
	self.physicsObject.friction = 2000
end

function Protagonist:Update( dt )
	Protagonist.super.Update( self, dt )

	self.position.x = (self.position.x > 1600 and 0) or (self.position.x < 0 and 1600) or self.position.x
	self.position.y = (self.position.y > 900 and 0) or (self.position.y < 0 and 900) or self.position.y
end

function Protagonist:Draw()
	love.graphics.push()
	love.graphics.translate( self.position.x, self.position.y )
	love.graphics.setColor( 255, 128, 128 )
	love.graphics.circle("fill", 0, 0, self.physicsObject.radius)
	love.graphics.pop()


	local rect_x1 = g_antagonist.position.x + g_antagonist.physicsObject.xExtent1
	local rect_y1 = g_antagonist.position.y + g_antagonist.physicsObject.yExtent1
	local rect_x2 = g_antagonist.position.x + g_antagonist.physicsObject.xExtent2
	local rect_y2 = g_antagonist.position.y + g_antagonist.physicsObject.yExtent2
	local circle_x = self.position.x
	local circle_y = self.position.y
	local circle_r = self.physicsObject.radius

	love.graphics.setColor( 255, 255, 0 )
	love.graphics.rectangle('line', rect_x1, rect_y1, rect_x2 - rect_x1, rect_y2 - rect_y1)
	
	local worldPhysicsObject = self.world.physicsObject
	local ignoreTable = {}
	ignoreTable[self.physicsObject] = true
	local foundObject = worldPhysicsObject:VisitRadius( circle_x, circle_y, circle_r, ignoreTable )
	if foundObject then
	--print(foundObject.gameObject.name)
		love.graphics.circle("line", circle_x, circle_y, circle_r)
		
	end
end
