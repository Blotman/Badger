require("Platform/GameObject")
require("Platform/Physics/WorldPhysicsObject")

class( "World" )

World.physicsCategories = {}
World.physicsCategories.static = 1
World.physicsCategories.projectile1 = 2
World.physicsCategories.projectile2 = 3
World.physicsCategories.character1 = 4
World.physicsCategories.character2 = 5

function World:__init( params )
	self.params = params
	self.name = params.strName
	self.physicsWorld = love.physics.newWorld( params.xExtent1, params.yExtent1, params.xExtent2, params.yExtent2, params.xGravity, params.yGravity, false )
	self.physicsWorld:setCallbacks( World.ObjectsCollided, World.ObjectsTouching, World.ObjectsUncollided )
	self.children = {}
	self.childrenIndices = {}
	self.camera = {}
	self.camera.position = Vector:New( 0, 0 )
end

function World:AddChild( child )
	table.insert( self.children, child )
	self.childrenIndices[child] = #self.children
end

function World:RemoveChild( child )
	local index = self.childrenIndices[child]
	if index ~= nil then
		table.remove(self.children, index)
	end
	self.childrenIndices[child] = nil
end

function World:Update( dt )
	self.physicsWorld:update( dt )

	for _, child in pairs(self.children) do
		child:Update(dt)
	end
end

function World:Draw()
	love.graphics.push()
	love.graphics.translate( 800 - self.camera.position.x, 450 - self.camera.position.y )
	for _, child in pairs(self.children) do
		child:Draw()
	end
	love.graphics.pop()
end

function World.ObjectsCollided(a, b, contactInfo)
	local contactInfo = {
		friction = contactInfo:getFriction(),
		normal = Vector:New( contactInfo:getNormal() ),
		position = Vector:New( contactInfo:getPosition() ),
		restitution = contactInfo:getRestitution(),
		separation = contactInfo:getSeparation(),
		velocity = Vector:New( contactInfo:getVelocity() )
	}
	if a.Collided then
		a:Collided( b, contactInfo )
	end

	if b.Collided then
		b:Collided( a, contactInfo )
	end
end

function World.ObjectsTouching(a, b, contactInfo)
	local contactInfo = {
		friction = contactInfo:getFriction(),
		normal = Vector:New( contactInfo:getNormal() ),
		position = Vector:New( contactInfo:getPosition() ),
		restitution = contactInfo:getRestitution(),
		separation = contactInfo:getSeparation(),
		velocity = Vector:New( contactInfo:getVelocity() )
	}
	if a.Touching then
		a:Touching( b, contactInfo )
	end

	if b.Touching then
		b:Touching( a, contactInfo )
	end
end

function World.ObjectsUncollided(a, b, contactInfo)
	local contactInfo = {
		friction = contactInfo:getFriction(),
		normal = Vector:New( contactInfo:getNormal() ),
		position = Vector:New( contactInfo:getPosition() ),
		restitution = contactInfo:getRestitution(),
		separation = contactInfo:getSeparation(),
		velocity = Vector:New( contactInfo:getVelocity() )
	}
	if a.Uncollided then
		a:Uncollided( b, contactInfo )
	end

	if b.Uncollided then
		b:Uncollided( a, contactInfo )
	end
end

function World:ToXML( depth )
	local output = {}
	depth = depth or 0
	local tab1 = string.rep("\t", depth)
	table.insert( output, string.format( [[%s<class name="%s">]], tab1, self.class.name ) )
	depth = depth + 1
	local tab2 = string.rep("\t", depth)
	for name, value in pairs( self.params ) do
		table.insert( output, string.format( [[%s<param name="%s" value="%s" type="%s" />]], tab2, name, value, type(value) ) )
	end
	table.insert( output, string.format( [[%s<children>]], tab2 ) )
	for _, child in pairs( self.children ) do
		table.insert( output, child:ToXML( depth+1 ) )
	end
	table.insert( output, string.format( [[%s</children>]], tab2 ) )
	table.insert( output, string.format( [[%s</class>]], tab1 ) )

	return table.concat(output, "\n")
end

function World:Save( fileName )
	local worldXML = self:ToXML( depth )
	love.filesystem.write( fileName, worldXML, string.len(worldXML) )
end
