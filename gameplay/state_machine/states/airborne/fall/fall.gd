class_name FallState 
extends State


var gravity : float = 0.0


func enter() -> void:
	gravity = character.get_gravity().y


func exit() -> void:
	gravity = 0.0


func process() -> void:
	_propagate_state()


func physics_process() -> void:
	character.velocity.y += gravity
	_propagate_state()
	_handle_transitions()


func _handle_transitions() -> void:
	pass
