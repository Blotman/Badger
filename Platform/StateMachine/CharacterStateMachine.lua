require("Platform/StateMachine/StateMachine")

class( "CharacterStateMachine" ):Extends( StateMachine )

function CharacterStateMachine:__init( owner )
	CharacterStateMachine.super.__init( self, owner )
	self:AddState("Entry")
	self:AddState("Active")
	self:AddState("Exit")

	self.currentState = "Entry"
end
