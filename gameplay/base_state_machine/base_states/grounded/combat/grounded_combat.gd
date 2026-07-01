class_name GroundedCombatState
extends State


func enter() -> void:
	_propagate_enter()


func exit() -> void:
	_propagate_exit()


func process() -> void:
	_propagate_process()


func physics_process() -> void:
	_propagate_physics_process()
	_handle_transitions()


func _handle_transitions() -> void:
	pass
