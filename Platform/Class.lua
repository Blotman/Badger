Class = {}

function Class.Define(name)
	local newClass = {name = name}

	function newClass:Extends(parent)
		self.super = parent
		setmetatable(self, {__index = parent})
	end

	function newClass:New(...)
		local classInstance = {className = self.name}
		setmetatable(classInstance, {__index = newClass})

		if classInstance.__init then
			classInstance:__init(...)
		end
		return classInstance
	end

	_G[name] = newClass

	return newClass
end

function Class.InstantiateFromTable(data)
	local instancedObject = _G[data.className] and _G[data.className]:New()
	if instancedObject.Deserialize then
		instancedObject:Deserialize(data)
	end
	data.className = nil

	for i, j in pairs(data) do
		if type(j) == "table" and j.className then
			instancedObject[i] = Class.InstantiateFromTable(j)
		else
			instancedObject[i] = j
		end
		data[i] = nil
	end

	return instancedObject
end

function Class.InstantiateFromFile(fileName)
	local instanceTable = love.filesystem.load( fileName )()
	return Class.InstantiateFromTable(instanceTable)
end