require("Platform/GameObject")

class("Body"):Extends( GameObject )

function Body:__init( params, world, physicsObject )
	Body.super.__init( self, params, world )
	self.physicsObject = physicsObject
end

function Body:Delete()
	if physicsObject ~= nil then
		self.physicsObject:destroy()
	end
	Body.super.Delete( self )
end

function Body:Update(dt)
	self.position:set( self.physicsBody:getPosition() )
end
