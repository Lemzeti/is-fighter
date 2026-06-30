class_name CrouchState
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
	_propagate_physics_process()

	if has_parent_state():
		direction = parent_state.direction
	character.velocity.x = direction * character.crouch_speed

	_handle_transitions()


func _handle_transitions() -> void:
	if not Input.is_action_pressed("crouch"): # Idle
		state_changed.emit(self, "idle")
