@abstract
class_name State
extends Node
## Base of the base State class for all character actions.
## Custom substates may be made to override existing base states.


@warning_ignore("unused_signal")
signal state_changed(state : State, new_state_name : String)


@export var parent_state : State :
	get:
		if parent_state == null:
			parent_state = (get_parent()) if (get_parent() is State) else (null)
		return parent_state


var character : Character = null

var propagation_enabled : bool = true


@onready var root_fsm : StateMachine = %StateMachine


func _ready() -> void:
	if root_fsm == null:
		push_error("Can't assign character because StateMachine is null.")
		return
	if parent_state == null:
		propagation_enabled = false
	character = root_fsm.character_parent as Character


@abstract func enter() -> void
@abstract func exit() -> void
@abstract func process() -> void
@abstract func physics_process() -> void

@abstract func _handle_transitions() -> void


func _propagate_enter() -> void:
	if not propagation_enabled:
		return
	parent_state.enter()


func _propagate_exit() -> void:
	if not propagation_enabled:
		return
	parent_state.exit()


func _propagate_process() -> void:
	if not propagation_enabled:
		return
	parent_state.process()


func _propagate_physics_process() -> void:
	if not propagation_enabled:
		return
	parent_state.physics_process()


func has_parent_state() -> bool:
	return (parent_state != null)
