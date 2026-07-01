class_name GuyHookState
extends State


@onready var guy : GuyCharacter = character as GuyCharacter


func enter() -> void:
	_propagate_enter()
	guy.basic_attack_duration_timer.wait_time = guy.hook_duration
	guy.basic_attack_duration_timer.start()


func exit() -> void:
	guy.basic_attack_combo_timer.stop()
	guy.basic_attack_duration_timer.stop()
	_propagate_exit()


func process() -> void:
	_propagate_process()


func physics_process() -> void:
	_propagate_physics_process()

	guy.hitbox.global_position = guy.hook_hitbox_position

	await guy.basic_attack_duration_timer.timeout

	_handle_transitions()


func _handle_transitions() -> void:
	if guy.basic_attack_cooldown_timer.is_stopped() and not guy.basic_attack_combo_timer.is_stopped():
		state_changed.emit(self, "uppercut")
	else:
		state_changed.emit(self, "idle")
