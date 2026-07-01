class_name Character
extends CharacterBody2D


@export_group("Display")
@export var nickname : String = ""
@export_multiline var description : String = ""

@export_group("Base Parameters")
@export var base_health : float = 100.0
@export var base_movement_speed : float = 800.0
@export var base_jump_velocity : float = 750.0
@export var base_crouch_speed : float = 400.0

@export_group("Skills")
@export_subgroup("Damage")
@export var basic_attack_damage : float = 1.0
@export var skill_one_damage : float = 3.0
@export var skill_two_damage : float = 5.0
@export var skill_three_damage : float = 7.0
@export var skill_ultimate_damage : float = 15.0

@export_subgroup("Cooldown") ## In seconds. Lower = faster.
@export var basic_attack_cooldown : float = 1.0
@export var skill_one_cooldown : float = 5.0
@export var skill_two_cooldown : float = 10.0
@export var skill_three_cooldown : float = 15.0
@export var skill_ultimate_cooldown : float = 20.0

@export_subgroup("Duration") ## In seconds. Lower = faster.
@export var basic_attack_duration : float = 0.05
@export var skill_one_duration : float = 0.1
@export var skill_two_duration : float = 0.12
@export var skill_three_duration : float = 0.125
@export var skill_ultimate_duration : float = 1.0

@export_subgroup("Hitbox Size")
@export var basic_attack_hitbox_size : Vector2 = Vector2.ZERO
@export var skill_one_hitbox_size : Vector2 = Vector2.ZERO
@export var skill_two_hitbox_size : Vector2 = Vector2.ZERO
@export var skill_three_hitbox_size : Vector2 = Vector2.ZERO
@export var skill_ultimate_hitbox_size : Vector2 = Vector2.ZERO

@export_subgroup("Hitbox Position")
@export var basic_attack_hitbox_position : Vector2 = Vector2.ZERO
@export var skill_one_hitbox_position : Vector2 = Vector2.ZERO
@export var skill_two_hitbox_position : Vector2 = Vector2.ZERO
@export var skill_three_hitbox_position : Vector2 = Vector2.ZERO
@export var skill_ultimate_hitbox_position : Vector2 = Vector2.ZERO

@export_group("Misc")
@export var jump_buffer_time : float = 0.15 ## In seconds.


var state : State = null

var health : float = 0.0
var movement_speed : float = 0.0
var jump_velocity : float = 0.0
var crouch_speed : float = 0.0

var direction : float = 0.0


@onready var state_machine : StateMachine = %StateMachine
@onready var sprite : AnimatedSprite2D = %Sprite
@onready var pivot : Node2D = %Pivot

@onready var basic_attack_cooldown_timer : Timer = %BasicAttackCooldownTimer
@onready var skill_one_cooldown_timer : Timer = %SkillOneCooldownTimer
@onready var skill_two_cooldown_timer : Timer = %SkillTwoCooldownTimer
@onready var skill_three_cooldown_timer : Timer = %SkillThreeCooldownTimer
@onready var skill_ultimate_cooldown_timer : Timer = %SkillUltimateCooldownTimer

@onready var basic_attack_duration_timer : Timer = %BasicAttackDurationTimer
@onready var skill_one_duration_timer : Timer = %SkillOneDurationTimer
@onready var skill_two_duration_timer : Timer = %SkillTwoDurationTimer
@onready var skill_three_duration_timer : Timer = %SkillThreeDurationTimer
@onready var skill_ultimate_duration_timer : Timer = %SkillUltimateDurationTimer

@onready var jump_buffer_timer : Timer = %JumpBufferTimer

@onready var hurtbox:  Hurtbox = %Hurtbox
@onready var hitbox : Hitbox = %Hitbox


func _ready() -> void:
	_init_character()


func _physics_process(_delta : float) -> void:
	_flip_according_to_move_direction()
	move_and_slide()


func _init_character() -> void:
	health = base_health
	movement_speed = base_movement_speed
	jump_velocity = base_jump_velocity
	crouch_speed = base_crouch_speed

	_init_cooldown_timers()
	_init_duration_timers()

	jump_buffer_timer.wait_time = jump_buffer_time
	jump_buffer_timer.one_shot = true


func _init_cooldown_timers() -> void:
	basic_attack_cooldown_timer.wait_time = basic_attack_cooldown
	basic_attack_cooldown_timer.one_shot = true

	skill_one_cooldown_timer.wait_time = skill_one_cooldown
	skill_one_cooldown_timer.one_shot = true

	skill_two_cooldown_timer.wait_time = skill_two_cooldown
	skill_two_cooldown_timer.one_shot = true

	skill_three_cooldown_timer.wait_time = skill_three_cooldown
	skill_three_cooldown_timer.one_shot = true

	skill_ultimate_cooldown_timer.wait_time = skill_ultimate_cooldown
	skill_ultimate_cooldown_timer.one_shot = true


func _init_duration_timers() -> void:
	basic_attack_duration_timer.wait_time = basic_attack_duration
	basic_attack_duration_timer.one_shot = true

	skill_one_duration_timer.wait_time = skill_one_duration
	skill_one_duration_timer.one_shot = true

	skill_two_duration_timer.wait_time = skill_two_duration
	skill_two_duration_timer.one_shot = true

	skill_three_duration_timer.wait_time = skill_three_duration
	skill_three_duration_timer.one_shot = true

	skill_ultimate_duration_timer.wait_time = skill_ultimate_duration
	skill_ultimate_duration_timer.one_shot = true


func _flip_according_to_move_direction() -> void:
	direction = state_machine.facing_direction
	if direction == -1:
		pivot.scale.x = -1
	elif direction == 1:
		pivot.scale.x = 1


func play_animation_according_to_state(anim : String) -> void:
	await ready
	if sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)
	else:
		push_error("Sprite has no '", anim, "' animation.")


func _on_basic_attack_duration_timer_timeout() -> void:
	basic_attack_cooldown_timer.start()


func _on_skill_one_duration_timer_timeout() -> void:
	skill_one_cooldown_timer.start()


func _on_skill_two_duration_timer_timeout() -> void:
	skill_two_cooldown_timer.start()


func _on_skill_three_duration_timer_timeout() -> void:
	skill_three_cooldown_timer.start()


func _on_skill_ultimate_duration_timer_timeout() -> void:
	skill_ultimate_cooldown_timer.start()
