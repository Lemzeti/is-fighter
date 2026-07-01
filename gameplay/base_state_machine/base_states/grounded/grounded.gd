class_name GroundedState
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
	if not character.is_on_floor():
		state_changed.emit(root_fsm.current_state, "fall")
	elif Input.is_action_just_pressed("jump") or not character.jump_buffer_timer.is_stopped():
		state_changed.emit(root_fsm.current_state, "jump")
	elif Input.is_action_just_pressed("crouch"):
		state_changed.emit(root_fsm.current_state, "crouch")
