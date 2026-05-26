class_name Character extends CharacterBody2D


const GRAVITY_CLAMP: float = 0.1
const ACCURATE_COLLISION_SCALING: float = 0.5


@export_group("Display")
@export var nickname: String = "" ## Character name.
@export_group("Stats")
@export var base_health: float = 100.0 ## Base character health.
@export var base_movement_speed: float = 800.0 ## Base character movement speed.
@export_group("Skills")
@export_subgroup("Damage") # In seconds
@export var basic_attack_damage: float = 1.0 ## Basic attack damage.
@export var skill_one_damage: float = 3.0 ## Skill one damage.
@export var skill_two_damage: float = 5.0 ## Skill two damage.
@export var skill_three_damage: float = 7.0 ## Skill three damage.
@export var ultimate_damage: float = 15.0 ## Ultimate skill damage.
@export_subgroup("Cooldown") # In seconds
@export var basic_attack_cooldown: float = 1.0 ## Basic attack cooldown (attack speed). Lower = faster.
@export var skill_one_cooldown: float = 5.0 ## Skill one cooldown.
@export var skill_two_cooldown: float = 10.0 ## Skill two cooldown.
@export var skill_three_cooldown: float = 15.0 ## Skill three cooldown.
@export var ultimate_cooldown: float = 20.0 ## Ultimate skill cooldown.
@export_subgroup("Hitbox Size")
@export var skill_one_hitbox_size: Vector2 = Vector2.ZERO ## Skill one hitbox size.
@export var skill_two_hitbox_size: Vector2 = Vector2.ZERO ## Skill two hitbox size.
@export var skill_three_hitbox_size: Vector2 = Vector2.ZERO ## Skill three hitbox size.
@export var ultimate_hitbox_size: Vector2 = Vector2.ZERO ## Ultimate skill hitbox size.
@export_subgroup("Hitbox Position")
@export var skill_one_hitbox_position: Vector2 = Vector2.ZERO ## Skill one hitbox position.
@export var skill_two_hitbox_position: Vector2 = Vector2.ZERO ## Skill two hitbox position.
@export var skill_three_hitbox_position: Vector2 = Vector2.ZERO ## Skill three hitbox position.
@export var ultimate_hitbox_position: Vector2 = Vector2.ZERO ## Ultimate skill hitbox position.
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
var last_direction: float = 1.0

var base_hitbox_position: Vector2 = Vector2.ZERO
var base_hitbox_size: Vector2 = Vector2.ZERO

var can_jump: bool = true
var can_attack: bool = true
var can_skill_one: bool = true
var can_skill_two: bool = true
var can_skill_three: bool = true
var can_ult: bool = true

var health: float = 0.0
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
	_setup()


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
	_flip_character()
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
	basic_attack_timer.start()


func _process_skill_one() -> void:
	can_skill_one = false
	_enable_hitbox()
	skill_one_timer.start()
	# skill 1
	_disable_hitbox() # move to subclass character


func _process_skill_two() -> void:
	can_skill_two = false
	_enable_hitbox()
	skill_two_timer.start()
	# skill 2
	_disable_hitbox() # move to subclass character


func _process_skill_three() -> void:
	can_skill_three = false
	_enable_hitbox()
	ultimate_timer.start()
	# skill 3
	_disable_hitbox() # move to subclass character


func _process_ultimate() -> void:
	can_ult = false
	_enable_hitbox()
	ultimate_timer.start()
	# ult
	_disable_hitbox() # move to subclass character


func _handle_animation() -> void:
	var current_anim := animations[current_state]
	if not _animation_playing(current_anim):
		anim_sprite.play(current_anim)


func _animation_playing(anim: String) -> bool:
	return anim_sprite.is_playing() and anim_sprite.animation == anim


func _flip_character() -> void:
	# Sprite
	anim_sprite.flip_h = direction < 0

	# Hitbox
	hitbox.position.x = -base_hitbox_position.x if last_direction < 0 else base_hitbox_position.x


func _setup() -> void:
	if not hitbox.disabled:
		hitbox.disabled = true
	base_hitbox_position = hitbox.position

	health = base_health
	movement_speed = base_movement_speed
	jump_velocity = base_jump_velocity
	crouch_speed = base_crouch_speed

	basic_attack_timer.wait_time = basic_attack_cooldown
	skill_one_timer.wait_time = skill_one_cooldown
	skill_two_timer.wait_time = skill_two_cooldown
	skill_three_timer.wait_time = skill_three_cooldown
	ultimate_timer.wait_time = ultimate_cooldown

	basic_attack_timer.one_shot = true
	skill_one_timer.one_shot = true
	skill_two_timer.one_shot = true
	skill_three_timer.one_shot = true
	ultimate_timer.one_shot = true

	if not basic_attack_timer.is_connected("timeout", Callable(self, "_on_basic_attack_timer_timeout")):
		basic_attack_timer.connect("timeout", Callable(self, "_on_basic_attack_timer_timeout"))
	if not skill_one_timer.is_connected("timeout", Callable(self, "_on_skill_one_timer_timeout")):
		skill_one_timer.connect("timeout", Callable(self, "_on_skill_one_timer_timeout"))
	if not skill_two_timer.is_connected("timeout", Callable(self, "_on_skill_two_timer_timeout")):
		skill_two_timer.connect("timeout", Callable(self, "_on_skill_two_timer_timeout"))
	if not skill_three_timer.is_connected("timeout", Callable(self, "_on_skill_three_timer_timeout")):
		skill_three_timer.connect("timeout", Callable(self, "_on_skill_three_timer_timeout"))
	if not ultimate_timer.is_connected("timeout", Callable(self, "_on_ultimate_timer_timeout")):
		ultimate_timer.connect("timeout", Callable(self, "_on_ultimate_timer_timeout"))


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


func _on_basic_attack_timer_timeout() -> void:
	print("bayes")
	can_attack = true
	_disable_hitbox()


func _on_skill_one_timer_timeout() -> void:
	print("s1yes")
	can_skill_one = true
	_disable_hitbox()


func _on_skill_two_timer_timeout() -> void:
	print("s2yes")
	can_skill_two = true
	_disable_hitbox()


func _on_skill_three_timer_timeout() -> void:
	print("s3yes")
	can_skill_three = true
	_disable_hitbox()


func _on_ultimate_timer_timeout() -> void:
	print("ultyes")
	can_ult = true
	_disable_hitbox()


func wait(time: float) -> void:
	await get_tree().create_timer(time).timeout
