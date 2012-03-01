require("Platform/Body")

class("Block"):Extends( Body )

function Block:__init( strName, world, x, y, mass, inertia, friction, width, height, angle )
	local vPos = Vector:New( x, y )
	Block.super.__init( self, strName, world, vPos, mass, inertia )
	self.physicsShape = love.physics.newRectangleShape( self.physicsBody, 0, 0, width, height, angle )
	self.physicsShape:setData( self )
	self.physicsShape:setCategory( World.physicsCategories.static )
	self.physicsShape:setFriction( friction or 0 )
end

function Block:Draw()
	love.graphics.push()
	love.graphics.setColor( 128, 128, 128 )
	love.graphics.polygon( "fill", self.physicsShape:getPoints() )
	love.graphics.pop()
end
