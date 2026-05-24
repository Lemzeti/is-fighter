class_name Character extends CharacterBody2D


const GRAVITY_CLAMP: float = 0.1


@export_group("Display")
@export var nickname: String = "" ## Character name.
@export_group("Stats")
@export var base_health: float = 100.0 ## Base character health.
@export var base_damage: float = 5.0 ## Base character attack damage.
@export var base_movement_speed: float = 800.0 ## Base character movement speed.
@export var base_attack_speed: float = 1.0 ## Base character basic attack speed. Lower = faster.
@export_group("Skills") # In seconds
@export var skill_one_cooldown: float = 5.0 ## Skill one cooldown.
@export var skill_two_cooldown: float = 10.0 ## Skill two cooldown.
@export var skill_three_cooldown: float = 15.0 ## Skill three cooldown.
@export var ultimate_cooldown: float = 20.0 ## Ultimate skill cooldown.
@export_group("Other parameters")
@export var base_jump_velocity: float = 1500.0 ## Base character jump height.
@export var base_crouch_speed: float = 400.0 ## Base character crouch speed.


enum State {
	IDLE,
	MOVING,
	JUMPED,
	MOVING_WHILE_FALLING,
	FALLING,
	CROUCHING,
	MOVING_WHILE_CROUCHING,
	BASIC_ATTACK,
	SKILL_ONE,
	SKILL_TWO,
	SKILL_THREE,
	SKILL_ULTIMATE
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
var last_direction: float = 0.0

var can_jump: bool = true
var can_attack: bool = true
var can_skill_one: bool = true
var can_skill_two: bool = true
var can_skill_three: bool = true
var can_ult: bool = true

var health: float = 0.0
var damage: float = 0.0
var movement_speed: float = 0.0
var jump_velocity: float = 0.0
var crouch_speed: float = 0.0


@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var jump_cooldown_timer: Timer = $JumpCooldownTimer
@onready var basic_attack_timer: Timer = $BasicAttackTimer
@onready var skill_one_timer: Timer = $SkillOneTimer
@onready var skill_two_timer: Timer = $SkillTwoTimer
@onready var skill_three_timer: Timer = $SkillThreeTimer
@onready var ultimate_timer: Timer = $UltimateTimer
@onready var hitbox: CollisionShape2D = $Hitbox/Collision


func _ready() -> void:
	anim_sprite.play("idle")
	_setup_stats()


func _physics_process(_delta: float) -> void:
	direction = Input.get_axis("move_left", "move_right")
	last_direction = direction if direction != 0.0 else last_direction

	can_jump = jump_cooldown_timer.is_stopped() and is_on_floor()
	can_attack = basic_attack_timer.is_stopped()
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
		State.FALLING: _process_falling(GRAVITY_CLAMP)
		State.CROUCHING: _process_crouching()
		State.MOVING_WHILE_CROUCHING: _process_moving_while_crouching()
		State.BASIC_ATTACK: _process_basic_attack()
		State.SKILL_ONE: _process_skill_one()
		State.SKILL_TWO: _process_skill_two()
		State.SKILL_THREE: _process_skill_three()
		State.SKILL_ULTIMATE: _process_ultimate()

	# Transition state
	if Input.is_action_pressed("ultimate") and can_ult:
		current_state = State.SKILL_ULTIMATE
	elif Input.is_action_pressed("skill_three") and can_skill_three:
		current_state = State.SKILL_THREE
	elif Input.is_action_pressed("skill_two") and can_skill_two:
		current_state = State.SKILL_TWO
	elif Input.is_action_pressed("skill_one") and can_skill_one:
		current_state = State.SKILL_ONE
	elif Input.is_action_just_pressed("basic_attack") and can_attack:
		current_state = State.BASIC_ATTACK
	elif Input.is_action_pressed("jump") and can_jump:
		current_state = State.JUMPED
	elif Input.is_action_pressed("crouch") and direction != 0.0:
		current_state = State.MOVING_WHILE_CROUCHING
	elif direction != 0.0 and not is_on_floor():
		current_state = State.MOVING_WHILE_FALLING
	elif Input.is_action_pressed("crouch"):
		current_state = State.CROUCHING
	elif direction != 0.0:
		current_state = State.MOVING
	elif not is_on_floor():
		current_state = State.FALLING
	else:
		current_state = State.IDLE

	_handle_animation()

	# Debug
	if current_state != State.IDLE:
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
	_process_falling(GRAVITY_CLAMP)


func _process_falling(gravity_multiplier: float) -> void:
	velocity.y += get_gravity().y * gravity_multiplier


func _process_crouching() -> void:
	if is_on_floor():
		pass # crouch logic, maybe shorten collision
	else:
		_process_falling(GRAVITY_CLAMP * 2.0)


func _process_moving_while_crouching() -> void:
	velocity.x = direction * crouch_speed
	_process_crouching()


func _process_basic_attack() -> void:
	can_attack = false
	_enable_hitbox()


func _process_skill_one() -> void:
	can_skill_one = false
	_enable_hitbox()
	skill_one_timer.start()


func _process_skill_two() -> void:
	can_skill_two = false
	_enable_hitbox()
	skill_two_timer.start()


func _process_skill_three() -> void:
	can_skill_three = false
	_enable_hitbox()
	ultimate_timer.start()


func _process_ultimate() -> void:
	can_ult = false
	_enable_hitbox()
	ultimate_timer.start()


func _handle_animation() -> void:
	var current_anim := animations[current_state]
	if not _animation_playing(current_anim):
		anim_sprite.play(current_anim)


func _animation_playing(anim: String) -> bool:
	return anim_sprite.is_playing() and anim_sprite.animation == anim


func _character_faces_move_direction() -> void:
	anim_sprite.flip_h = direction < 0


func _setup_stats() -> void:
	if not hitbox.disabled:
		hitbox.disabled = true

	health = base_health
	damage = base_damage
	movement_speed = base_movement_speed
	jump_velocity = base_jump_velocity
	crouch_speed = base_crouch_speed

	basic_attack_timer.wait_time = base_attack_speed
	skill_one_timer.wait_time = skill_one_cooldown
	skill_two_timer.wait_time = skill_two_cooldown
	skill_three_timer.wait_time = skill_three_cooldown
	ultimate_timer.wait_time = ultimate_cooldown


func _enable_hitbox() -> void:
	hitbox.disabled = false


func _disable_hitbox() -> void:
	hitbox.disabled = true


func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0.0:
		# die
		pass


func _on_jump_cooldown_timer_timeout() -> void:
	can_jump = true
	_disable_hitbox()


func _on_basic_attack_timer_timeout() -> void:
	can_attack = true
	_disable_hitbox()


func _on_skill_one_timer_timeout() -> void:
	can_skill_one = true
	_disable_hitbox()


func _on_skill_two_timer_timeout() -> void:
	can_skill_two = true
	_disable_hitbox()


func _on_skill_three_timer_timeout() -> void:
	can_skill_three = true
	_disable_hitbox()


func _on_ultimate_timer_timeout() -> void:
	can_ult = true
	_disable_hitbox()
