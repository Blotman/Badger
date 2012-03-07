Class = {}

function Class.Define(name)
	local newClass = {name = name}

	function newClass:Extends(parent)
		self.super = parent
		setmetatable(self, {__index = parent})
	end

	newClass.InstantiateFromXMLTable = function( data, parent )
		local params = {}
		local childrenTable = {}
		for _, j in ipairs( data ) do
			if j.label == "param" then
				params[j.xarg.name] = j.xarg.type == number and tonumber( j.xarg.value ) or j.xarg.value
			elseif j.label == "children" then
				childrenTable = j
			end
		end

		local instantiatedObject = newClass.New( newClass, params, parent )

		for i, j in ipairs(childrenTable) do
			InstantiateFromXMLTable( j, instantiatedObject )
		end

		return instantiatedObject
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

function Class.InstantiateFromXMLTable(data, parent)
	local instantiatedObject = nil
	if data.xarg and data.xarg.name then
		instantiatedObject = _G[data.xarg.name].InstantiateFromXMLTable(data, parent)
	end

	return instantiatedObject
end
