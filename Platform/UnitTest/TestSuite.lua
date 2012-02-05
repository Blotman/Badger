require("Platform/Util")

class "TestSuite"

function TestSuite:__init()
	self.textFixtures = {}
end

function TestSuite:AddFixture( fixture )
	table.insert( self.textFixtures, fixture )
end

function TestSuite:Run()
	local pass = true
	self:SetUp()
	for _, testFixture in ipairs(self.textFixtures) do
		pass = testFixture:Run()
	end
	self:TearDown()

	return pass
end
