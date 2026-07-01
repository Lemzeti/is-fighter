class_name GuyCharacter
extends Character


@export_group("Basic Attack Combo Parameters")
@export var combo_window : float = 1.55

@export_subgroup("Duration")
@export var jab_duration : float = 0.01
@export var hook_duration : float = 0.01
@export var uppercut_duration : float = 0.2

@export_subgroup("Hitbox Position")
@export var jab_hitbox_position : Vector2 = Vector2.ZERO
@export var hook_hitbox_position : Vector2 = Vector2.ZERO
@export var uppercut_hitbox_position : Vector2 = Vector2.ZERO


@onready var basic_attack_combo_timer : Timer = %BasicAttackComboTimer


func _init_character() -> void:
	super()
	basic_attack_combo_timer.wait_time = combo_window
	basic_attack_combo_timer.one_shot = true


func _on_basic_attack_duration_timer_timeout() -> void:
	super()
	basic_attack_combo_timer.start()
