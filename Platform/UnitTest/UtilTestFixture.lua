require("Platform/UnitTest/TestFixture")
require("Platform/Util")


UtilTestFixture = TestFixture:New()

function UtilTestFixture:SetUp()
end

function UtilTestFixture:TestTableToString1()
	return self:AssertEquals( "{}", ToString( {} ) )
end

function UtilTestFixture:TestTableToString2()
	local expected = [[{
  ["a"]=1,
  ["c"]=3,
  ["b"]=2,
}]]
	return self:AssertEquals( expected, ToString( { a = 1, b = 2, c = 3 } ) )
end

function UtilTestFixture:TestTableToString3()
	local expected = [[{
  ["a"]=1,
  ["b"]={
    ["c"]=3,
  },
}]]
	return self:AssertEquals( expected, ToString( { a = 1, b = { c = 3} } ) )
end

function UtilTestFixture:TestPointRectIntersect1()
	local point_x, point_y = 0, 0
	local rect_x1, rect_y1 = 0, 0
	local rect_x2, rect_y2 = 0, 0

	return self:AssertTrue( PointRectIntersect( point_x, point_y, rect_x1, rect_y1, rect_x2, rect_y2 ) )
end

function UtilTestFixture:TearDown()
end

local results = UtilTestFixture:Run()
for _, fixtureResults in ipairs( results ) do
	print( fixtureResults.name, fixtureResults.result and "passed" or "failed", fixtureResults.message )
end