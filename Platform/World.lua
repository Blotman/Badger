require("Platform/GameObject")

class "World" {}
World:extends(GameObject)

function World:__init()
	World.super.__init(self)
end
