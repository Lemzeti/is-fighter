extends Character


@export_group("Parameters")
@export var combo_time: float = 0.7
@export_subgroup("Attack")
@export var dash_punch_distance: float = 5000.0
@export var dash_punch_speed: float = 1200.0

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


@onready var basic_attack_combo_timer: Timer = $BasicAttackComboTimer


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

	basic_attack_combo_timer.start()


func _jab() -> void:
	print("fritz_combo1_jab")


func _cross() -> void:
	print("fritz_combo2_cross")


func _front_kick() -> void:
	print("fritz_combo3_frontkick")


func _dash_punch() -> void:
	print("fritz_combo4_dashpunch")
	velocity.x += dash_punch_distance * last_direction
	_enable_hitbox()
	


func _process_skill_one() -> void:
	super()


func _process_skill_two() -> void:
	super()


func _process_skill_three() -> void:
	super()


func _process_ultimate() -> void:
	super()


func _setup() -> void:
	super()

	# Basic attack phase damage
	jab_damage = basic_attack_damage
	cross_damage = basic_attack_damage * 1.25
	front_kick_damage = basic_attack_damage * 2.0
	dash_punch_damage = basic_attack_damage * 2.5
