require("Platform/Util")

class "StateMachine"

function StateMachine:__init( owner, startState )
	self.owner = owner
	self.startState = startState
	self.states = {}
end

function StateMachine:AddState( stateName, updateCallback )
	self.states[stateName] = { events = {} }
end

function StateMachine:AddEvent( originStateName, eventName, targetStateName )
	self.states[originStateName].events[eventName] = { transitionStateName = targetStateName, callbacks = {} }
end

function StateMachine:SetCallback( stateName, callbackName, callback )
	local state = self.states[stateName]
	if state then
		state[callbackName] = callback
	end
end

function StateMachine:SetEnterCallback( stateName, callback )
	self:SetCallback( stateName, "Enter", callback )
end

function StateMachine:SetUpdateCallback( stateName, callback )
	self:SetCallback( stateName, "Update", callback )
end

function StateMachine:SetDrawCallback( stateName, callback )
	self:SetCallback( stateName, "Draw", callback )
end

function StateMachine:SetExitCallback( stateName, callback )
	self:SetCallback( stateName, "Exit", callback )
end

function StateMachine:SetStateCallbacks( stateName, enterCallback, updateCallback, drawCallback, exitCallback )
	self:SetEnterCallback( stateName, enterCallback )
	self:SetUpdateCallback( stateName, updateCallback )
	self:SetDrawCallback( stateName, drawCallback )
	self:SetExitCallback( stateName, exitCallback )
end

function StateMachine:TransitionState( stateName )
	if self.currentState and self.currentState.Exit then
		self.currentState.Exit( self.owner )
	end

	self.currentStateName = stateName
	self.currentState = self.states[self.currentStateName]
	assert( self.currentState )
	if self.currentState.Enter then
		self.owner[self.currentState.Enter]( self.owner )
	end
end

function StateMachine:TriggerEvent( eventName )
	local event = self.currentState.events[eventName]
	for eventCallback, callbackObject in pairs( event.callbacks ) do
		eventCallback( callbackObject )
	end
	
	if event.transitionStateName then
		self:TransitionState( event.transitionStateName )
	end
end

function StateMachine:Update( dt )
	if not self.currentStateName then
		self:TransitionState( self.startState )
	end

	assert( self.currentState )
	if self.currentState.Update then
		self.owner[self.currentState.Update]( self.owner, dt )
	end
end

function StateMachine:Draw()
	assert( self.currentState )
	if self.currentState.Draw then
		self.owner[self.currentState.Draw]( self.owner, dt )
	end
end