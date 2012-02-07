require("Platform/Util")

TestFixture = {}

function TestFixture:New()
	local instance = {}
	instance.testCases = {}
	
	function instance:AssertEquals( expected, actual )
		local result = expected == actual
		local message = result and "" or string.format( "%s does not equal %s", tostring(actual), tostring(expected) )
		return result, message
	end

	function instance:AssertTrue( test )
		local result = test == true
		local message = result and "" or string.format( "Expected true, but got false" )
		return result, message
	end
	
	function instance:Run()
		local results = {}
		if instance.SetUp then
			instance:SetUp()
		end

		for _, testName in ipairs( self.testCases ) do
			local testCase = self[testName]
			if type( testCase ) == "function" then
				local testResult, testMessage = testCase(instance)
				local testInfo = {
					name = testName,
					result = testResult,
					message = testMessage
				}

				table.insert( results, testInfo )
			end
		end

		if instance.TearDown then
			instance:TearDown()
		end

		return results
	end
	
	local mt = {}
	mt.__newindex = function( t, key, value )
		if key ~= "SetUp" and key ~= "TearDown" then
			table.insert( t.testCases, key )
		end
		rawset( t, key, value )
	end
	setmetatable(instance, mt)

	return instance
end