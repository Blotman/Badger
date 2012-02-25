require("Character")

class("Antagonist"):Extends( Character )

function Antagonist:__init( strName, world, x, y )
	Antagonist.super.__init( self, strName, world, x, y, 70, 100, 5 )

	self.physicsCapsuleTopShape:setCategory( World.physicsCategories.character2 )
	self.physicsCapsuleMiddleShape:setCategory( World.physicsCategories.character2 )
	self.physicsCapsuleBottomShape:setCategory( World.physicsCategories.character2 )
end

function Antagonist:ActiveDraw()
	love.graphics.push()
	love.graphics.setColor( 0, 255, 255 )
	local halfWidth = self.width / 2
	local halfHeight = self.height / 2
	love.graphics.circle("fill", self.physicsBody:getX(), self.physicsBody:getY() - halfHeight + halfWidth, self.physicsCapsuleTopShape:getRadius(), 20)
	love.graphics.polygon( "fill", self.physicsCapsuleMiddleShape:getPoints() )
	love.graphics.circle("fill", self.physicsBody:getX(), self.physicsBody:getY() + halfHeight - halfWidth, self.physicsCapsuleBottomShape:getRadius(), 20)
	love.graphics.pop()
end
