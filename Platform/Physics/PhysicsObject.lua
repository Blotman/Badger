require("Platform/Util")

class "PhysicsObject"

function PhysicsObject:__init( gameObject )
	self.gameObject = gameObject
	self.velocity = Vector:New(0, 0, 0)
	self.acceleration = Vector:New(0, 0, 0)
	self.maxSpeed = -1
	self.friction = 0
	self.quadNodes = {}
end

function PhysicsObject:Update( dt )
	self.velocity:add( self.acceleration:_mul( dt ) )
	local speed = self.velocity:len()
	if speed > 0 then
		local newSpeed = nil
		if self.friction > 0 then
			newSpeed = (speed < self.friction * dt and 0) or (speed - self.friction * dt)
		end

		if self.maxSpeed >= 0 then
			if speed > self.maxSpeed then
				newSpeed = self.maxSpeed
			end
		end

		if newSpeed ~= nil then
			self.velocity:mul( newSpeed / speed )
		end
	end

	self.gameObject.position:add( self.velocity:_mul( dt ) )
end

function PhysicsObject:Serialize(depth)
	local serialized = {}
	table.insert( serialized, "{" )
	SerializeHelper( self, serialized, {"className", "velocity", "acceleration", "maxSpeed", "friction"}, depth+1)
	table.insert( serialized, "\n" .. Tab(depth) .. "}" )

	return table.concat(serialized)
end
