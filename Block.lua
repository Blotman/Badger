require("Platform/Body")

class("Block"):Extends( Body )

function Block:__init( params, world )
	Block.super.__init( self, params, world )
	self.physicsShape = love.physics.newRectangleShape( self.physicsBody, 0, 0, params.width, params.height, params.angle )
	self.physicsShape:setData( self )
	self.physicsShape:setCategory( World.physicsCategories.static )
	self.physicsShape:setFriction( params.friction or 0 )
end

function Block:Draw()
	love.graphics.push()
	love.graphics.setColor( 128, 128, 128 )
	love.graphics.polygon( "fill", self.physicsShape:getPoints() )
	love.graphics.pop()
end
