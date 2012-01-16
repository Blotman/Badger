require( "Platform/Util" )
require( "Platform/World" )

class( "Editor" ):Extends( World )

function Editor:__init( strName, world, xExtent1, yExtent1, xExtent2, yExtent2 )
	Editor.super.__init( self, strName, xExtent1, yExtent1, xExtent2, yExtent2 )
	self.world = world
	self.selectedObject = nil
	self.heldObject = nil
	self.mouseClicked = Vector:New( -1, -1 )
	self.objectClicked = Vector:New( -1, -1 )
end

function Editor:Update( dt )
	if self.heldObject then
		local mouseDelta = Vector:New( love.mouse.getPosition() )
		mouseDelta:sub( self.mouseClicked )
		self.heldObject.position:set( self.objectClicked.x, self.objectClicked.y )
		self.heldObject.position:add( mouseDelta )
	end
end

function Editor:Draw()
	if self.selectedObject then
		local gameObjectPosition = self.selectedObject.position
		local selectedPhysicsObject = self.selectedObject.physicsObject
		love.graphics.push()
		love.graphics.translate( gameObjectPosition.x, gameObjectPosition.y )
		love.graphics.setColor( 255, 255, 0 )
		love.graphics.polygon("line", {	selectedPhysicsObject.xExtent1, selectedPhysicsObject.yExtent1,
										selectedPhysicsObject.xExtent2, selectedPhysicsObject.yExtent1,
										selectedPhysicsObject.xExtent2, selectedPhysicsObject.yExtent2,
										selectedPhysicsObject.xExtent1, selectedPhysicsObject.yExtent2})
		love.graphics.pop()
	end
end

function Editor:SelectObject( object )
	self.selectedObject = object
end

function Editor:HoldObject( object, x, y )
	self.heldObject = object
	if self.heldObject then
		self.mouseClicked:set( x, y )
		self.objectClicked:set( self.heldObject.position.x, self.heldObject.position.y )
	end
end

function Editor:ReleaseObject( x, y )
	self.heldObject = nil
end