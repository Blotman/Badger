require("Platform/Util")

class "StateMachine"

function StateMachine:__init( owner )
	self.owner = owner
	self.states = {}
end

function StateMachine:AddState( stateName, updateCallback )
	self.states[stateName] = {}
end

function StateMachine:SetUpdateCallback( stateName, callback )
	local state = self.states[stateName]
	if state then
		state.Update = callback
	end
end

function StateMachine:SetDrawCallback( stateName, callback )
	local state = self.states[stateName]
	if state then
		state.Draw = callback
	end
end

function StateMachine:Update( dt )
	self.states[self.currentState].Update( self.owner, dt )
end

function StateMachine:Draw()
	self.states[self.currentState].Draw( self.owner )
end