@abstract
class_name State
extends Node


@warning_ignore("unused_signal")
signal state_changed(state : State, new_state_name : String)


var parent_state : State = null
var character : Character = null


@onready var root_fsm : StateMachine = %StateMachine


func _ready() -> void:
	if root_fsm == null:
		push_error("Can't assign character because StateMachine is null.")
		return
	character = root_fsm.character_parent as Character


@abstract func enter() -> void
@abstract func exit() -> void
@abstract func process() -> void
@abstract func physics_process() -> void

@abstract func _handle_transitions() -> void


func _propagate_state() -> void:
	parent_state = (get_parent()) if (get_parent() is State) else (null)
	if parent_state == null:
		print("State ", name.to_upper(), " has no parent state.")
		return

	parent_state.process()
	parent_state.physics_process()
