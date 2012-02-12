require("Platform/UnitTest/TestFixture")
require("Platform/Physics/PhysicsObject")
require("Platform/Physics/WorldPhysicsObject")


WorldTestFixture = TestFixture:New()

function WorldTestFixture:SetUp()
	self.world = WorldPhysicsObject:New( nil, 8, 0, 0, 128, 128 )

	self.object1 = PhysicsObject:New()
	self.object2 = PhysicsObject:New()
	
	self.world:AddChild( self.object1 )
	self.world:AddChild( self.object2 )
end

function WorldTestFixture:TestVisitRect1()
	self.object1.position:set( 5, 5, 0 )
	self.world:ObjectMoved( self.object1 )

	local visitedObjects = self.world:VisitRect( 0, 0, 5, 5 )
	return self:AssertTrue( visitedObjects[self.object1] )
end


function WorldTestFixture:TestVisitWorld1()
	self.object1.position:set( 5, 5, 0 )
	self.world:ObjectMoved( self.object1 )

	self.object2.position:set( 50, 50, 0 )
	self.world:ObjectMoved( self.object2 )

	local visitedObjects = self.object1:VisitWorld()
	return self:AssertNil( visitedObjects[self.object2] )
end

function WorldTestFixture:TestVisitWorld2()
	self.object1.position:set( 5, 5, 0 )
	self.world:ObjectMoved( self.object1 )
	
	self.object2.position:set( 6, 6, 0 )
	self.world:ObjectMoved( self.object2 )
	
	local visitedObjects = self.object1:VisitWorld()
	return self:AssertTrue( visitedObjects[self.object2] )
end
--[[
function WorldTestFixture:TestCollisionInfo1()
	self.object1.position:set( 5, 5, 0 )
	self.object2.position:set( 6, 6, 0 )

	local visitedObjects = self.object1:VisitWorld()
	return self:AssertTrue( visitedObjects[self.object2] )
end
--]]
function WorldTestFixture:TearDown()
end

local results = WorldTestFixture:Run()
for _, fixtureResults in ipairs( results ) do
	print( fixtureResults.name, fixtureResults.result and "passed" or "failed", fixtureResults.message )
end