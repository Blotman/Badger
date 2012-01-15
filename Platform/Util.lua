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

function PointRectIntersect( point_x, point_y, rect_x1, rect_y1, rect_x2, rect_y2 )
	return point_x >= rect_x1 and point_x <= rect_x2 and point_y >= rect_y1 and point_y <= rect_y2
end

function RectRectIntersect( rect1_x1, rect1_y1, rect1_x2, rect1_y2, rect2_x1, rect2_y1, rect2_x2, rect2_y2 )
	local function segmentIntersects( a_x1, a_x2, b_x1, b_x2 )
		return a_x1 <= b_x1 and a_x2 >= b_x2 or a_x1 >= b_x1 and a_x2 <= b_x2
	end
	return segmentIntersects(rect1_x1, rect1_x2, rect2_x1, rect2_x2 ) and segmentIntersects(rect1_y1, rect1_y2, rect2_y1, rect2_y2 )
end
