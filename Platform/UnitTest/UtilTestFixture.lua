require("Platform/UnitTest/TestFixture")
require("Platform/Util")


UtilTestFixture = TestFixture:New()

function UtilTestFixture:SetUp()
end

function UtilTestFixture:TestTableToString()
	local result = true
	self:AssertEquals( "{", ToString( {} ) )

	return result
end

function UtilTestFixture:TestPointRectIntersect()
	print( "test 3" )
end

function UtilTestFixture:TearDown()
	print( "test 4" )
end

UtilTestFixture:Run()