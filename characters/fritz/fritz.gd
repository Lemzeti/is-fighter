extends Character


@export_group("Basic Attack Combo")
@export var combo_time: float = 0.7
@export_subgroup("Dash")
@export var dash_punch_distance: float = 5000.0
@export var dash_punch_duration: float = 1.0
@export var dash_punch_speed: float = 1200.0
@export_subgroup("Hitbox Size")
@export var jab_hitbox_size: Vector2 = Vector2.ZERO
@export var cross_hitbox_size: Vector2 = Vector2.ZERO
@export var front_kick_hitbox_size: Vector2 = Vector2.ZERO
@export var dash_punch_hitbox_size: Vector2 = Vector2.ZERO
@export_subgroup("Hitbox Position")
@export var jab_hitbox_position: Vector2 = Vector2.ZERO
@export var cross_hitbox_position: Vector2 = Vector2.ZERO
@export var front_kick_hitbox_position: Vector2 = Vector2.ZERO
@export var dash_punch_hitbox_position: Vector2 = Vector2.ZERO


enum AttackPhase {
	JAB,
	CROSS,
	FRONT_KICK,
	DASH_PUNCH,
}

var current_phase: AttackPhase = AttackPhase.JAB

var jab_damage: float = 0.0
var cross_damage: float = 0.0
var front_kick_damage: float = 0.0
var dash_punch_damage: float = 0.0


@onready var basic_attack_combo_timer: Timer = $Timers/BasicAttackComboTimer


func _ready() -> void:
	super()
	basic_attack_combo_timer.wait_time = combo_time


func _process_basic_attack() -> void:
	super()

	# Process phase
	match current_phase:
		AttackPhase.JAB: _jab()
		AttackPhase.CROSS: _cross()
		AttackPhase.FRONT_KICK: _front_kick()
		AttackPhase.DASH_PUNCH: _dash_punch()

	# Transition phase
	if not basic_attack_combo_timer.is_stopped():
		current_phase = ((current_phase + 1) % AttackPhase.size()) as AttackPhase
	else:
		current_phase = AttackPhase.JAB
		_set_hitbox(current_phase)

	basic_attack_combo_timer.start()


func _jab() -> void:
	print("fritz_combo1_jab")
	_set_hitbox(current_phase)


func _cross() -> void:
	print("fritz_combo2_cross")
	_set_hitbox(current_phase)


func _front_kick() -> void:
	print("fritz_combo3_frontkick")
	_set_hitbox(current_phase)


func _dash_punch() -> void:
	print("fritz_combo4_dashpunch")
	await wait(dash_punch_duration)
	velocity.x = dash_punch_distance * last_direction
	_set_hitbox(current_phase)
	_enable_hitbox()


func _process_skill_one() -> void:
	super()


func _process_skill_two() -> void:
	super()


func _process_skill_three() -> void:
	super()


func _process_skill_ultimate() -> void:
	super()


func _setup() -> void:
	super()

	# Basic attack phase damage
	jab_damage = basic_attack_damage
	cross_damage = basic_attack_damage * 1.25
	front_kick_damage = basic_attack_damage * 2.0
	dash_punch_damage = basic_attack_damage * 2.5

	# Hitbox
	_set_hitbox(current_phase)


func _set_hitbox(phase: AttackPhase) -> void:
	match phase:
		AttackPhase.JAB:
			hitbox.position = Vector2(jab_hitbox_position.x * last_direction, jab_hitbox_position.y)
			hitbox.shape.size = Vector2(jab_hitbox_size.x * last_direction, jab_hitbox_size.y)
		AttackPhase.CROSS:
			hitbox.position = Vector2(cross_hitbox_position.x * last_direction, cross_hitbox_position.y)
			hitbox.shape.size = Vector2(cross_hitbox_size.x * last_direction, cross_hitbox_size.y)
		AttackPhase.FRONT_KICK:
			hitbox.position = Vector2(front_kick_hitbox_position.x * last_direction, front_kick_hitbox_position.y)
			hitbox.shape.size = Vector2(front_kick_hitbox_size.x * last_direction, front_kick_hitbox_size.y)
		AttackPhase.DASH_PUNCH:
			hitbox.position = Vector2(dash_punch_hitbox_position.x * last_direction, dash_punch_hitbox_position.y)
			hitbox.shape.size = Vector2(dash_punch_hitbox_size.x * last_direction, dash_punch_hitbox_size.y)
