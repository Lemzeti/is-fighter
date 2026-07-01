class_name AirborneState
extends State


var direction : float = 0.0


func enter() -> void:
	_propagate_enter()
	direction = 0.0


func exit() -> void:
	direction = 0.0
	_propagate_exit()


func process() -> void:
	_propagate_process()


func physics_process() -> void:
	direction = Input.get_axis("move_left", "move_right")
	root_fsm.facing_direction = direction

	_handle_transitions()


func _handle_transitions() -> void:
	if character.is_on_floor():
		state_changed.emit(root_fsm.current_state, "idle")
