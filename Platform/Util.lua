require("Platform/Class")

function class(name)
	return Class.Define(name)
end

function ToString(data, initialDepth, minimal)
	local tostringWrapper = {}
	tostringWrapper.string = function(data) return string.format( "\"%s\"", tostring(data) )end
	tostringWrapper.table = function(data, depth, tracer)
		tracer = tracer or {}
		local retVal = nil
		if tracer[data] == nil then
			tracer[data] = true
			local serialized = {}
			depth = depth and depth + 1 or 1
			local count = 0
			table.insert( serialized, "{" )
			for key, value in pairs( data ) do
				local keyFunc = tostringWrapper[type(key)]
				local keyString = (not keyFunc) and tostring(key) or keyFunc(key)

				local valueFunc = tostringWrapper[type(value)]
				local valueString = (not valueFunc) and tostring(value) or valueFunc(value, depth, tracer)

				if valueString ~= nil then
					if (not minimal) then
						table.insert( serialized, "\n" .. Tab(depth) )
						count = count + 1
					end
					table.insert( serialized, string.format("[%s]=%s,", keyString, valueString) )
				end
			end
			if not minimal and count > 0 then
				table.insert( serialized, "\n" .. Tab(depth-1) )
			end
			table.insert( serialized, "}" )
			retVal = table.concat(serialized)
		end
		return retVal
	end

	local dataType = type(data)
	return tostringWrapper[dataType] and tostringWrapper[dataType](data, initialDepth) or tostring(data)
end

function Tab(depth)
	local formatString = "%" .. tostring(depth*2) .. "s"
	return depth > 0 and string.format( formatString, " " ) or ""
end

function SerializeHelper( self, appendTable, attributeList, depth )
	for _, attribute in ipairs(attributeList) do
		local attributeValue = self[attribute]
		if attributeValue then
			local attributeString = type(attributeValue) == "table" and attributeValue.Serialize and attributeValue:Serialize(depth) or ToString(attributeValue)
			table.insert( appendTable, string.format( "\n%s%s=%s,", Tab(depth), attribute, attributeString) )
		end
	end
end