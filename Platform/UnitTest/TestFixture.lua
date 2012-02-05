require("Platform/Util")

TestFixture = {}

function TestFixture:New()
	local instance = {}
	instance.testCases = {}
	
	function instance:AssertEquals( expected, actual, description )
		if expected ~= actual then
			error( description or "" )
		end
	end
	
	function instance:Run()
		if instance.SetUp then
			instance:SetUp()
		end

		for _, testName in ipairs( self.testCases ) do
			local testCase = self[testName]
			if type( testCase ) == "function" then
				testCase(instance)
			end
		end

		if instance.TearDown then
			instance:TearDown()
		end
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