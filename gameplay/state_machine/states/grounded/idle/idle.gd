class_name IdleState 
extends State


var input : float = 0.0


func enter() -> void:
	input = 0.0


func exit() -> void:
	input = 0.0


func process() -> void:
	_propagate_state()


func physics_process() -> void:
	input = Input.get_axis("move_left", "move_right")
	_propagate_state()

	_handle_transitions()


func _handle_transitions() -> void:
	if input != 0.0: # Moving
		state_changed.emit(self, "move")
