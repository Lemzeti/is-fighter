class_name MoveState
extends State


var direction : float = 0.0


func enter() -> void:
	direction = 0.0


func exit() -> void:
	direction = 0.0


func process() -> void:
	_propagate_state()


func physics_process() -> void:
	direction = Input.get_axis("move_left", "move_right")
	character.velocity.x = direction * character.movement_speed
	print(character.movement_speed)
	_propagate_state()

	_handle_transitions()


func _handle_transitions() -> void:
	if direction == 0.0:
		state_changed.emit(self, "idle")
