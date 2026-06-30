class_name IdleState 
extends State


var input : float = 0.0


func enter() -> void:
	_propagate_enter()
	input = 0.0


func exit() -> void:
	input = 0.0
	_propagate_exit()


func process() -> void:
	_propagate_process()


func physics_process() -> void:
	_propagate_physics_process()

	if has_parent_state():
		input = parent_state.direction

	_handle_transitions()


func _handle_transitions() -> void:
	if input != 0.0: # Moving
		state_changed.emit(self, "move")
