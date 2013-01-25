require( "Platform/Util" )
require( "Platform/UI/PropertiesPane" )

class( "Editor" )

function Editor:__init( params, world )
	self.world = world
	self.xExtent1 = params.xExtent1
	self.yExtent1 = params.yExtent1
	self.xExtent2 = params.xExtent2
	self.yExtent2 = params.yExtent2
	self.selectedObject = nil
	self.heldObject = nil
	self.mouseClicked = Vector:New( -1, -1 )
	self.objectClickedPosition = Vector:New( -1, -1 )
	self.propertiesPane = PropertiesPane:New( "", 0, 0, 250, 500 )
end

function Editor:Update( dt )
	if self.heldObject then
		local mouseDelta = Vector:New( love.mouse.getPosition() )
		mouseDelta:sub( self.mouseClicked )
		self.heldObject.physicsObject.position:set( self.objectClickedPosition )
		self.heldObject.physicsObject.position:add( mouseDelta )
	end

	self.propertiesPane.physicsObject.position.x = self.xExtent2 - self.propertiesPane.width
	self.propertiesPane.physicsObject.position.y = 0
	self.propertiesPane:Update( dt )
end

function Editor:Draw()
	if self.selectedObject then
		local selectedPhysicsObject = self.selectedObject.physicsObject
		local gameObjectPosition = selectedPhysicsObject.position
		love.graphics.push()
		love.graphics.translate( gameObjectPosition.x, gameObjectPosition.y )
		love.graphics.setColor( 255, 255, 0 )
		love.graphics.polygon("line", {	selectedPhysicsObject.xExtent1, selectedPhysicsObject.yExtent1,
										selectedPhysicsObject.xExtent2, selectedPhysicsObject.yExtent1,
										selectedPhysicsObject.xExtent2, selectedPhysicsObject.yExtent2,
										selectedPhysicsObject.xExtent1, selectedPhysicsObject.yExtent2})
		love.graphics.pop()
	end
	
	self.propertiesPane:Draw()
end

function Editor:SelectObject( object )
	self.selectedObject = object
	self.propertiesPane:SelectObject( object )
end

function Editor:HoldObject( object, x, y )
	self.heldObject = object
	if self.heldObject then
		self.mouseClicked:set( x, y )
		self.objectClickedPosition:set( self.heldObject.position )
	end
end

function Editor:ReleaseObject( x, y )
	self.heldObject = nil
end