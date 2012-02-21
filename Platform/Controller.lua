require("Platform/Util")

class "Controller"

function Controller:__init()
end

Controller.KeyState = {
	up = false,
	down = false,
	left = false,
	right = false,
	attack = false,
	escape = false,
}
Controller.KeyMapping = {
	w = "up",
	s = "down",
	a = "left",
	d = "right",
	up = "up",
	down = "down",
	left = "left",
	right = "right",
	[" "] = "attack",
	escape = "escape"
}