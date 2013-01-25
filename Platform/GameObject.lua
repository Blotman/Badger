require("Platform/Util")
require("Platform/Vector")

class "GameObject"

function GameObject:__init( params, world )
	self.params = params
	self.name = params.strName
	self.position = Vector:New(params.x, params.y, params.z)
	self.children = {}
	self.world = world

	world:AddChild( self )
end

function GameObject:Delete()
	for child, _ in pairs(self.children) do
		child:Delete()
	end
	self.world:RemoveChild( self )
end

function GameObject:AddChild( child )
	table.insert(self.children, child)
end

function GameObject:Update(dt)
	if self.physicsBody ~= nil then
		self.position:set( self.physicsBody.position )
	end
	for child, _ in pairs(self.children) do
		child:Update(dt)
	end
end

function GameObject:Draw()
	for child, _ in pairs(self.children) do
		child:Draw()
	end
end

function GameObject:ToXML( depth )
	local output = {}
	depth = depth or 0
	local tab1 = string.rep("\t", depth)
	table.insert( output, string.format( [[%s<class name="%s">]], tab1, self.class.name ) )
	depth = depth + 1
	local tab2 = string.rep("\t", depth)
	for name, value in pairs( self.params ) do
		table.insert( output, string.format( [[%s<param name="%s" value="%s" type="%s" />]], tab2, name, value, type(value) ) )
	end
	table.insert( output, string.format( [[%s</class>]], tab1 ) )

	return table.concat(output, "\n")
end

function GameObject:SetPhysicsObject( physicsObject )
	self.physicsObject = physicsObject
	self.physicsObject.gameObject = self
	
	self.world.physicsObject:AddChild(self.physicsObject)
end
