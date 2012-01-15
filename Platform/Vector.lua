require("Platform/Util")

class "Vector"

function Vector:__init(x, y, z)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
end

function Vector:set(x, y, z)
	self.x = x
	self.y = y
	self.z = z
	return self
end

function Vector:setLength(length)
	self:normalize_inplace()
	self:mul(length)
	return self
end

function Vector:add(a)
	self.x = self.x + a.x
	self.y = self.y + a.y
	self.z = self.z + a.z
	return self
end

function Vector:mul(a)
	local otherType = type(a)
	if otherType == "number" then
		self.x = self.x * a
		self.y = self.y * a
		self.z = self.z * a
	end
	return self
end

function Vector:_mul(a)
	local otherType = type(a)
	local newVec = otherType == "number" and Vector:New( self.x * a, self.y * a, self.z * a )
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

function Vector:normalize_inplace()
	local l = self:len()
	if l ~= 0 then
		self.x = self.x / l
		self.y = self.y / l
		self.z = self.z / l
	end
	return self
end

function Vector:normalized()
	return self / self:len()
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
