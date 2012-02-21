require("Platform/GameObject")

class("Body"):Extends( GameObject )

function Body:__init( strName, world, vPos, mass, inertia )
	Body.super.__init( self, strName, world, vPos )
	self.physicsBody = love.physics.newBody( world.physicsWorld, self.position.x, self.position.y, mass, insertia )
end

function Body:Update(dt)
	self.position:set( self.physicsBody:getPosition() )
end
