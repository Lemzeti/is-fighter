class_name Character extends CharacterBody2D


@export_group("Display")
@export var character_name: String = ""
@export var character_sprite: Texture = null
@export_group("Stats")
@export var base_health: float = 100.0
@export var base_damage: float = 5.0
@export var base_movement_speed: float = 400.0
@export var base_attack_speed: float = 1.0
@export_group("Other parameters")
@export var base_jump_velocity: float = 800.0
@export var base_crouch_speed: float = 200.0


enum State {
	IDLE,
	MOVING,
	JUMPED,
	MOVING_WHILE_FALLING,
	FALLING,
	CROUCHING,
	MOVING_WHILE_CROUCHING,
	BASIC_ATTACK,
	SKILL_ONE_ATTACK,
	SKILL_TWO_ATTACK,
	SKILL_THREE_ATTACK,
	ULT_ATTACK
}

var current_state: State = State.IDLE

# Must match AnimatedSprite animation names
var animations: Array[String] = [
	"idle",
	"move",
	"jump",
	"move_while_fall",
	"fall",
	"crouch",
	"move_while_crouch",
	"basic_attack",
	"skill_one",
	"skill_two",
	"skill_three",
	"ultimate",
]

var direction: float = 0.0
var can_jump: bool = true
var can_skill_one: bool = true
var can_skill_two: bool = true
var can_skill_three: bool = true
var can_ult: bool = true

var health: float = 0.0
var damage: float = 0.0
var movement_speed: float = 0.0
var attack_speed: float = 0.0
var jump_velocity: float = 0.0
var crouch_speed: float = 0.0


@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var jump_cooldown_timer: Timer = $JumpCooldownTimer
@onready var skill_one_timer: Timer = $SkillOneTimer
@onready var skill_two_timer: Timer = $SkillTwoTimer
@onready var skill_three_timer: Timer = $SkillThreeTimer
@onready var ultimate_timer: Timer = $UltimateTimer


func _ready() -> void:
	anim_sprite.play("idle")
	_setup_stats()


func _physics_process(_delta: float) -> void:
	direction = Input.get_axis("move_left", "move_right")
	can_jump = jump_cooldown_timer.is_stopped() and is_on_floor()
	can_skill_one = skill_one_timer.is_stopped()
	can_skill_two = skill_two_timer.is_stopped()
	can_skill_three = skill_three_timer.is_stopped()
	can_ult = ultimate_timer.is_stopped()

	# Process state
	match current_state:
		State.IDLE: _process_idle()
		State.MOVING: _process_moving()
		State.JUMPED: _process_jumped()
		State.MOVING_WHILE_FALLING: _process_moving_while_falling()
		State.FALLING: _process_falling()
		State.CROUCHING: _process_crouching()
		State.MOVING_WHILE_CROUCHING: _process_moving_while_crouching()
		State.BASIC_ATTACK: _process_basic_attack()
		State.SKILL_ONE_ATTACK: _process_skill_one()
		State.SKILL_TWO_ATTACK: _process_skill_two()
		State.SKILL_THREE_ATTACK: _process_skill_three()
		State.ULT_ATTACK: _process_ultimate()

	# Transition state
	if Input.is_action_pressed("ultimate") and can_ult:
		current_state = State.ULT_ATTACK
	elif Input.is_action_pressed("skill_three") and can_skill_three:
		current_state = State.SKILL_THREE_ATTACK
	elif Input.is_action_pressed("skill_two") and can_skill_two:
		current_state = State.SKILL_TWO_ATTACK
	elif Input.is_action_pressed("skill_one") and can_skill_one:
		current_state = State.SKILL_ONE_ATTACK
	elif Input.is_action_pressed("jump") and can_jump:
		current_state = State.JUMPED
	elif Input.is_action_pressed("crouch") and direction != 0.0:
		current_state = State.MOVING_WHILE_CROUCHING
	elif Input.is_action_pressed("crouch"):
		current_state = State.CROUCHING
	elif direction != 0.0 and not is_on_floor():
		current_state = State.MOVING_WHILE_FALLING
	elif direction != 0.0:
		current_state = State.MOVING
	elif not is_on_floor():
		current_state = State.FALLING
	else:
		current_state = State.IDLE

	_handle_animation()

	print(animations[current_state])

	move_and_slide()


func _process_idle() -> void:
	if velocity.x != 0.0:
		velocity.x = 0.0


func _process_moving() -> void:
	_character_faces_move_direction()
	velocity.x = direction * movement_speed


func _process_jumped() -> void:
	can_jump = false
	jump_cooldown_timer.start()
	velocity.y -= jump_velocity


func _process_moving_while_falling() -> void:
	_process_moving()
	_process_falling()


func _process_falling() -> void:
	velocity.y += get_gravity().y * 0.1


func _process_crouching() -> void:
	if is_on_floor():
		pass # crouch logic
	else:
		_process_falling()


func _process_moving_while_crouching() -> void:
	velocity.x = direction * crouch_speed


func _process_basic_attack() -> void:
	pass


func _process_skill_one() -> void:
	pass


func _process_skill_two() -> void:
	pass


func _process_skill_three() -> void:
	pass


func _process_ultimate() -> void:
	pass


func _handle_animation() -> void:
	var current_anim := animations[current_state]
	if not _animation_playing(current_anim):
		anim_sprite.play(current_anim)


func _animation_playing(anim: String) -> bool:
	return anim_sprite.is_playing() and anim_sprite.animation == anim


func _character_faces_move_direction() -> void:
	anim_sprite.flip_h = direction < 0


func _setup_stats() -> void:
	health = base_health
	damage = base_damage
	movement_speed = base_movement_speed
	attack_speed = base_attack_speed
	jump_velocity = base_jump_velocity
	crouch_speed = base_crouch_speed


func _on_jump_cooldown_timer_timeout() -> void:
	can_jump = true
