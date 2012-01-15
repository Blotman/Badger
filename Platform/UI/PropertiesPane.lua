require("Platform/UI/Pane")
require("Platform/Physics/PhysicsObject")

class("PropertiesPane"):Extends( Pane )

function PropertiesPane:__init( strName, x, y, width, height )
	PropertiesPane.super.__init( self, strName, x, y, width, height )
	self.selectedObect = nil
end

function PropertiesPane:Update(dt)
	PropertiesPane.super.Update(self, dt)
end

function PropertiesPane:Draw()
	PropertiesPane.super.Draw(self)
	if self.selectedObect then
		love.graphics.push()
		love.graphics.translate( self.position.x, self.position.y )
		love.graphics.setColor( 0, 0, 0 )
		local propertiesBuilder = {}
		table.insert( propertiesBuilder, string.format( "Class: %s\n", self.selectedObect.className ) )
		table.insert( propertiesBuilder, string.format( "Name: %s\n", self.selectedObect.name ) )
		table.insert( propertiesBuilder, string.format( "Position: %d, %d, %d\n", self.selectedObect.position.x, self.selectedObect.position.y, self.selectedObect.position.z ) )
		love.graphics.print( table.concat(propertiesBuilder), 0, 0 )
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.pop()
	end
end

function PropertiesPane:SelectObject(object)
	self.selectedObect = object
end