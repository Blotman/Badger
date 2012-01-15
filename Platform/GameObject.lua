require("Platform/Util")
require("Platform/Vector")

class "GameObject"

function GameObject:__init( strName, vPos, physicsObject )
	self.name = strName
	self.position = vPos or Vector:New()
	self.physicsObject = physicsObject
	self.children = {}
	self.world = nil
end

function GameObject:SetWorld( worldObject )
	self.world = worldObject
	for i, child in ipairs( self.children ) do
		child:SetWorld( worldObject )
	end
end

function GameObject:AddChild( child )
	table.insert(self.children, child)
end

function GameObject:Update(dt)
	if self.physicsObject ~= nil then
		self.physicsObject:Update(dt)
	end
	for _, child in ipairs(self.children) do
		child:Update(dt)
	end
end

function GameObject:Draw()
	for _, child in ipairs(self.children) do
		child:Draw()
	end
end

function GameObject:SerializeAttributes(depth)
	local attributesTable = {}
	SerializeHelper( self, attributesTable, {"className", "name", "position", "physicsObject"}, depth)
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
	if data.physicsObject then
		self.physicsObject = Class.InstantiateFromTable(data.physicsObject)
		self.physicsObject.gameObject = self
		data.physicsObject = nil
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
