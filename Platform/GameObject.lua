require("Platform/Util")
require("Platform/Vector")

class "GameObject"

function GameObject:__init( strName, world, vPos )
	self.name = strName
	self.position = vPos or Vector:New()
	self.children = {}
	self.world = world
	world:AddChild( self )
end

function GameObject:Delete()
	for child, _ in pairs(self.children) do
		child:Delete()
	end
	self.world:RemoveChild( self )
end

function GameObject:AddChild( child )
	table.insert(self.children, child)
end

function GameObject:Update(dt)
	if self.physicsBody ~= nil then
		self.position:set( self.physicsBody.position )
	end
	for child, _ in pairs(self.children) do
		child:Update(dt)
	end
end

function GameObject:Draw()
	for child, _ in pairs(self.children) do
		child:Draw()
	end
end

function GameObject:SerializeAttributes(depth)
	local attributesTable = {}
	SerializeHelper( self, attributesTable, {"className", "name", "position", "physicsBody"}, depth)
	table.insert( attributesTable, string.format("\n%schildren={", Tab(depth)) )
	for i, child in ipairs(self.children) do
		local temp = string.format("\n%s[%s]=%s,", Tab(depth+1), tostring(i), child:Serialize(depth+1))
		table.insert(attributesTable, temp)
	end
	table.insert( attributesTable, string.format("\n%s}", Tab(depth)) )
	return attributesTable
end

function GameObject:Serialize(depth)
	depth = depth or 0
	local serializeData = {}
	table.insert( serializeData, "{" )
	table.insert( serializeData, table.concat(self:SerializeAttributes(depth+1)) )
	table.insert( serializeData, "\n" .. Tab(depth) .. "}" )
	return table.concat(serializeData)
end

function GameObject:Deserialize(data)
	self.name = data.name
	self.position:Deserialize(data.position)
	data.position = nil
	if data.physicsBody then
		self.physicsBody = Class.InstantiateFromTable(data.physicsBody)
		self.physicsBody.gameObject = self
		data.physicsBody = nil
	end
	if data.children then
		for i, j in ipairs(data.children) do
			self.children[i] = Class.InstantiateFromTable(j)
		end
		data.children = nil
	end
end

function GameObject:Save(fileName)
	local objectString = "return " .. self:Serialize(0)
	love.filesystem.write( fileName, objectString, string.len(objectString) )
end
