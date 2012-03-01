require("Platform/GameObject")
require("Platform/Physics/WorldPhysicsObject")

class( "World" )

World.physicsCategories = {}
World.physicsCategories.static = 1
World.physicsCategories.projectile1 = 2
World.physicsCategories.projectile2 = 3
World.physicsCategories.character1 = 4
World.physicsCategories.character2 = 5

function World:__init( strName, xExtent1, yExtent1, xExtent2, yExtent2, xGravity, yGravity )
	self.name = strName
	self.physicsWorld = love.physics.newWorld( xExtent1, yExtent1, xExtent2, yExtent2, xGravity, yGravity, false )
	self.physicsWorld:setCallbacks( World.ObjectsCollided, World.ObjectsTouching, World.ObjectsUncollided )
	self.children = {}
	self.camera = {}
	self.camera.position = Vector:New( 0, 0 )
end

function World:AddChild( child )
	self.children[child] = true
end

function World:RemoveChild( child )
	self.children[child] = nil
end

function World:Update( dt )
	self.physicsWorld:update( dt )

	for child, _ in pairs(self.children) do
		child:Update(dt)
	end
end

function World:Draw()
	love.graphics.push()
	love.graphics.translate( 800 - self.camera.position.x, 450 - self.camera.position.y )
	for child, _ in pairs(self.children) do
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
