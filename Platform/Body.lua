require("Platform/GameObject")

class("Body"):Extends( GameObject )

function Body:__init( params, world )
	Body.super.__init( self, params, world )
	self.physicsBody = love.physics.newBody( world.physicsWorld, self.position.x, self.position.y, params.mass, params.insertia )
end

function Body:Delete()
	self.physicsBody:destroy()
	Body.super.Delete( self )
end

function Body:Update(dt)
	self.position:set( self.physicsBody:getPosition() )
end
