require("Platform/Util")

class "Vector"

function Vector:__init(x, y, z)
	if type(x) == "table" and x:IsA( Vector ) then
		self.x = x.x or 0
		self.y = x.y or 0
		self.z = x.z or 0
	else
		self.x = x or 0
		self.y = y or 0
		self.z = z or 0
	end
end

function Vector:set(x, y, z)
	if type(x) == "table" and x:IsA( Vector ) then
		self.x = x.x or 0
		self.y = x.y or 0
		self.z = x.z or 0
	else
		self.x = x or 0
		self.y = y or 0
		self.z = z or 0
	end
	return self
end

function Vector:setLength(length)
	self:normalize()
	self:mul(length)
	return self
end

function Vector:add(x, y, z)
	if type(x) == "table" and x:IsA( Vector ) then
		self.x = self.x + x.x
		self.y = self.y + x.y
		self.z = self.z + x.z
	else
		self.x = self.x + (x or 0)
		self.y = self.y + (y or 0)
		self.z = self.z + (z or 0)
	end
	return self
end

function Vector:sub(x, y, z)
	if type(x) == "table" and x:IsA( Vector ) then
		self.x = self.x - x.x
		self.y = self.y - x.y
		self.z = self.z - x.z
	else
		self.x = self.x - (x or 0)
		self.y = self.y - (y or 0)
		self.z = self.z - (z or 0)
	end
	return self
end

function Vector:_sub( ... )
	return Vector:New( self ):sub( ... )
end

function Vector:mul(x)
	if type(x) == "table" and x:IsA( Vector ) then
		self.x = self.x * x.x
		self.y = self.y * x.y
		self.z = self.z * x.z
	else
		self.x = self.x * x
		self.y = self.y * x
		self.z = self.z * x
	end
	return self
end

function Vector:_mul(x)
	local newVec = (type(x) == "table" and x:IsA( Vector )) and Vector:New( self.x * x.x, self.y * x.y, self.z * x.z ) or Vector:New( self.x * x, self.y * x, self.z * x )
	return newVec
end

function Vector:len2()
	return self.x * self.x + self.y * self.y + self.z * self.z
end

function Vector:len()
	return math.sqrt(self:len2())
end

function Vector.dist(a, b)
	assert(isvector(a) and isvector(b), "dist: wrong argument types (<Vector> expected)")
	return (b-a):len()
end

function Vector:normalize()
	local l = self:len()
	if l ~= 0 then
		self.x = self.x / l
		self.y = self.y / l
		self.z = self.z / l
	end
	return self
end

function Vector:rotate_inplace(phi)
	local c, s = cos(phi), sin(phi)
	self.x, self.y = c * self.x - s * self.y, s * self.x + c * self.y
	return self
end

function Vector:rotated(phi)
	return self:clone():rotate_inplace(phi)
end

function Vector:perpendicular()
	return new(-self.y, self.x)
end

function Vector:projectOn(v)
	assert(isvector(v), "invalid argument: cannot project onto anything other than a Vector")
	return (self * v) * v / v:len2()
end

function Vector:mirrorOn(other)
	assert(isvector(other), "invalid argument: cannot mirror on anything other than a Vector")
	return 2 * self:projectOn(other) - self
end

function Vector:cross(other)
	assert(isvector(other), "cross: wrong argument types (<Vector> expected)")
	return self.x * other.y - self.y * other.x
end

function Vector:equals(other)
	return self.x == other.x and
			self.y == other.y and
			self.z == other.z
end

function Vector:Serialize(depth)
	return ToString(self, depth)
end

function Vector:Deserialize(data)
	self.x = data.x
	self.y = data.y
	self.z = data.z
	return self
end
