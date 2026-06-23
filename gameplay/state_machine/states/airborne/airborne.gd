class_name AirborneState
extends State


func enter() -> void:
	pass


func exit() -> void:
	pass


func process() -> void:
	pass


func physics_process() -> void:
	_handle_transitions()


func _handle_transitions() -> void:
	if character.is_on_floor():
		state_changed.emit(self, "idle")
