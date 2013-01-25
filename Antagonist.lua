require("Character")

class("Antagonist"):Extends( Character )

function Antagonist:__init( params, world )
	params.width = 70
	params.height = 100
	params.mass = 5
	

--[[	self.physicsCapsuleTopShape:setCategory( World.physicsCategories.character2 )
	self.physicsCapsuleMiddleShape:setCategory( World.physicsCategories.character2 )
	self.physicsCapsuleBottomShape:setCategory( World.physicsCategories.character2 )--]]

	Antagonist.super.__init( self,  params, world )
end

function Antagonist:ActiveDraw()
	love.graphics.push()
	love.graphics.setColor( 0, 255, 255 )
	local halfWidth = self.width / 2
	local halfHeight = self.height / 2
	love.graphics.circle("fill", self.physicsObject:GetX(), self.physicsObject:GetY() - halfHeight + halfWidth, self.physicsObject:GetRadius(), 20)
	love.graphics.polygon( "fill", self.physicsObject:GetPoints() )
	love.graphics.circle("fill", self.physicsObject:GetX(), self.physicsObject:GetY() + halfHeight - halfWidth, self.physicsObject:GetRadius(), 20)
	love.graphics.pop()
end
