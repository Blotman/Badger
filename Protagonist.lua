require("Character")

class("Protagonist"):Extends( Character )

function Protagonist:__init( params, world )
	params.width = 70
	params.height = 100
	params.mass = 5
	Protagonist.super.__init( self, params, world )

	--[[self.physicsCapsuleTopShape:setCategory( World.physicsCategories.character1 )
	self.physicsCapsuleMiddleShape:setCategory( World.physicsCategories.character1 )
	self.physicsCapsuleBottomShape:setCategory( World.physicsCategories.character1 )--]]

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
	love.graphics.translate( self.physicsObject:GetX(), self.physicsObject:GetY() )
	self.physicsObject:Draw()
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
	local currentVelocity = Vector:New( 0 )
	
	local maxSpeed = 1000
	local squareSpeed = currentVelocity:len2()
	if squareSpeed > math.pow( maxSpeed, 2 ) then
		local speedAdjust = maxSpeed / math.sqrt(squareSpeed)
		--self.physicsObject:setLinearVelocity( speedAdjust * currentVelocity.x, speedAdjust * currentVelocity.y )
	end

	--self.physicsObject:setLinearDamping( bestGrounding > 0 and 10 * bestGrounding or .33 )
	--self.physicsObject:applyForce( horizontalForce, 0 )
	--self.physicsObject:applyImpulse( 0, verticalImpulse )
	

	self.timeSinceLast = self.timeSinceLast and self.timeSinceLast + dt or 0.25
	if Controller.KeyState.attack then
		if self.timeSinceLast > 0.01 then
			Projectile.count = Projectile.count and Projectile.count + 1 or 1
			--g_count = g_count and g_count + 1 or 1
			self.timeSinceLast = 0
			Projectile:New( {	strName ="bullet_" .. tostring(Projectile.count),
												x = self.position.x + self.width / 2.0,
												y = self.position.y },
												self.world ).physicsObject:applyImpulse( 1000, 0 )
			--print( g_projectile.name, Projectile.count )
		end
	end
	
	self.touchingTable = {}
	self.touchingCount = 0

	self.super.Update( self, dt )
end