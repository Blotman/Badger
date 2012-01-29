Class = {}

function Class.Define(name)
	local newClass = {name = name}

	function newClass:Extends(parent)
		self.super = parent
		setmetatable(self, {__index = parent})
	end

	function newClass:New(...)
		local classInstance = {}
		classInstance.class = self
		classInstance.IsA = function( self, classType )
			local retVal = false
			while classType do
				if self.class == classType then
					retVal = true
					break
				else
					classType = classType.super
				end
			end
			
			return retVal
		end
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
	local instancedObject = _G[data.class.name] and _G[data.class.name]:New()
	if instancedObject.Deserialize then
		instancedObject:Deserialize(data)
	end
	data.class.name = nil

	for i, j in pairs(data) do
		if type(j) == "table" and j.class.name then
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