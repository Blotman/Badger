require("Character")

class("Protagonist"):Extends( Character )

function Protagonist:__init( params, world )
	params.width = 70
	params.height = 100
	params.mass = 5
	Protagonist.super.__init( self, params, world )

	self.physicsCapsuleTopShape:setCategory( World.physicsCategories.character1 )
	self.physicsCapsuleMiddleShape:setCategory( World.physicsCategories.character1 )
	self.physicsCapsuleBottomShape:setCategory( World.physicsCategories.character1 )

	self.touchingTable = {}
	self.touchingCount = 0
end

function Protagonist:Touching( other, contactInfo )
	if other:IsA( Block ) then
		self.touchingTable[other] = contactInfo
	end
end

function Protagonist:ActiveDraw()
	love.graphics.push()
	love.graphics.setColor( 255, 128, 128 )
	local halfWidth = self.width / 2
	local halfHeight = self.height / 2
	love.graphics.circle("line", self.physicsBody:getX(), self.physicsBody:getY() - halfHeight + halfWidth, self.physicsCapsuleTopShape:getRadius(), 20)
	love.graphics.polygon( "line", self.physicsCapsuleMiddleShape:getPoints() )
	love.graphics.circle("line", self.physicsBody:getX(), self.physicsBody:getY() + halfHeight - halfWidth, self.physicsCapsuleBottomShape:getRadius(), 20)
	love.graphics.translate( self.position.x, self.position.y )
	love.graphics.circle("fill", 0, -self.height / 3, self.physicsCapsuleTopShape:getRadius() / 2, 20)
	love.graphics.setColor( 0, 128, 255 )
	love.graphics.polygon( "fill", -self.width / 4, -self.height / 4, self.width / 4, -self.height / 4, self.width / 4, self.height / 4, -self.width / 4, self.height / 4 )
	love.graphics.pop()
end

function Protagonist:Update( dt )
	local bestGrounding = 0.0
	for other, contactInfo in pairs( self.touchingTable ) do
		local iteratedGrounding = -contactInfo.normal.y / self.world.physicsWorld:getMeter()
		bestGrounding = iteratedGrounding > bestGrounding and iteratedGrounding or bestGrounding
	end

	local adjustedGrounding = (bestGrounding > 0 and bestGrounding or 0.075)
	local horizontalForce = adjustedGrounding * 1000.0 * ((Controller.KeyState.right and 1.0 or 0.0) - (Controller.KeyState.left and 1.0 or 0.0))
	local verticalImpulse = bestGrounding * 75.0 * -(Controller.KeyState.up and 1.0 or 0.0)
	--print( bestGrounding )

	--local velocity = Vector:New( (	Controller.KeyState.right and 1.0 or 0.0) - (Controller.KeyState.left and 1.0 or 0.0),
		--							(Controller.KeyState.down and 1.0 or 0.0) - (Controller.KeyState.up and 1.0 or 0.0), 0.0 )
	--velocity:setLength(500)
	local currentVelocity = Vector:New( self.physicsBody:getLinearVelocity() )
	
	local maxSpeed = 1000
	local squareSpeed = currentVelocity:len2()
	if squareSpeed > math.pow( maxSpeed, 2 ) then
		local speedAdjust = maxSpeed / math.sqrt(squareSpeed)
		self.physicsBody:setLinearVelocity( speedAdjust * currentVelocity.x, speedAdjust * currentVelocity.y )
	end

	self.physicsBody:setLinearDamping( bestGrounding > 0 and 10 * bestGrounding or .33 )
	self.physicsBody:applyForce( horizontalForce, 0 )
	self.physicsBody:applyImpulse( 0, verticalImpulse )
	

	self.timeSinceLast = self.timeSinceLast and self.timeSinceLast + dt or 0.25
	if Controller.KeyState.attack then
		if self.timeSinceLast > 0.01 then
			g_count = g_count and g_count + 1 or 1
			self.timeSinceLast = 0
			g_projectile = Projectile:New( "bullet_" .. tostring(g_count), self.world, self.position.x + self.width / 2.0, self.position.y )
			g_projectile.physicsBody:applyImpulse( 1000, 0 )
		end
	end
	
	self.touchingTable = {}
	self.touchingCount = 0

	self.super.Update( self, dt )
end