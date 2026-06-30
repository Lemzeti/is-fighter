class_name Character
extends CharacterBody2D


@export_group("Display")
@export var nickname : String = "" ## Character name.
@export_multiline var description : String = "" ## Character description.

@export_group("Base Parameters")
@export var base_health : float = 100.0 ## Base character health.
@export var base_movement_speed : float = 800.0 ## Base character movement speed.
@export var base_jump_velocity : float = 750.0 ## Base character jump height.
@export var base_crouch_speed : float = 400.0 ## Base character crouch speed.

@export_group("Skills")
@export_subgroup("Damage")
@export var basic_attack_damage : float = 1.0 ## Basic attack damage.
@export var skill_one_damage : float = 3.0 ## Skill one damage.
@export var skill_two_damage : float = 5.0 ## Skill two damage.
@export var skill_three_damage : float = 7.0 ## Skill three damage.
@export var ultimate_damage : float = 15.0 ## Ultimate skill damage.

@export_subgroup("Cooldown") ## In seconds. Lower = faster.
@export var basic_attack_cooldown : float = 1.0 ## Basic attack cooldown (attack speed).
@export var skill_one_cooldown : float = 5.0 ## Skill one cooldown.
@export var skill_two_cooldown : float = 10.0 ## Skill two cooldown.
@export var skill_three_cooldown : float = 15.0 ## Skill three cooldown.
@export var ultimate_cooldown : float = 20.0 ## Ultimate skill cooldown.

@export_subgroup("Hitbox Size")
@export var skill_one_hitbox_size : Vector2 = Vector2.ZERO ## Skill one hitbox size.
@export var skill_two_hitbox_size : Vector2 = Vector2.ZERO ## Skill two hitbox size.
@export var skill_three_hitbox_size : Vector2 = Vector2.ZERO ## Skill three hitbox size.
@export var ultimate_hitbox_size : Vector2 = Vector2.ZERO ## Ultimate skill hitbox size.

@export_subgroup("Hitbox Position")
@export var skill_one_hitbox_position : Vector2 = Vector2.ZERO ## Skill one hitbox position.
@export var skill_two_hitbox_position : Vector2 = Vector2.ZERO ## Skill two hitbox position.
@export var skill_three_hitbox_position : Vector2 = Vector2.ZERO ## Skill three hitbox position.
@export var ultimate_hitbox_position : Vector2 = Vector2.ZERO ## Ultimate skill hitbox position.

@export_group("Misc")
@export var jump_buffer_time : float = 0.15 ## In seconds; when still falling and pressed jump, hold jump input for [param jump_buffer_time] seconds.


var health : float = 0.0
var movement_speed : float = 0.0
var jump_velocity : float = 0.0
var crouch_speed : float = 0.0

var direction : float = 0.0


@onready var state_machine : StateMachine = %StateMachine
@onready var jump_buffer_timer : Timer = %JumpBufferTimer
@onready var pivot : Node2D = %Pivot



func _ready() -> void:
	_init_character()


func _physics_process(_delta: float) -> void:
	_flip_according_to_move_direction()
	move_and_slide()


func _init_character() -> void:
	# Stats
	health = base_health
	movement_speed = base_movement_speed
	jump_velocity = base_jump_velocity
	crouch_speed = base_crouch_speed

	# Jump buffer
	jump_buffer_timer.wait_time = jump_buffer_time
	jump_buffer_timer.one_shot = true


func _flip_according_to_move_direction() -> void:
	direction = state_machine.facing_direction
	if direction == -1:
		pivot.scale.x = -1
	elif direction == 1:
		pivot.scale.x = 1
