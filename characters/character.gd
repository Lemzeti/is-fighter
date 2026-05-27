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
@export var base_jump_velocity: float = 1000.0 ## Base character jump height.
@export var base_crouch_speed: float = 400.0 ## Base character crouch speed.


enum State {
	IDLE,
	MOVING,
	JUMPED,
	JUMPING,
	FALLING,
	CROUCHING,
	USE_BASIC_ATTACK,
	USE_SKILL_ONE,
	USE_SKILL_TWO,
	USE_SKILL_THREE,
	USE_SKILL_ULTIMATE,
	MOVING_WHILE_JUMPING,
	MOVING_WHILE_FALLING,
	MOVING_WHILE_CROUCHING,
	USING_BASIC_ATTACK,
	USING_SKILL_ONE,
	USING_SKILL_TWO,
	USING_SKILL_THREE,
	USING_SKILL_ULTIMATE
}

var current_state: State = State.IDLE

# Must match AnimatedSprite animation names
var animations: Array[String] = [
	"IDLE",
	"MOVING",
	"JUMPED",
	"JUMPING",
	"FALLING",
	"CROUCHING",
	"USE_BASIC_ATTACK",
	"USE_SKILL_ONE",
	"USE_SKILL_TWO",
	"USE_SKILL_THREE",
	"USE_SKILL_ULTIMATE",
	"MOVING_WHILE_JUMPING",
	"MOVING_WHILE_FALLING",
	"MOVING_WHILE_CROUCHING",
	"USING_BASIC_ATTACK",
	"USING_SKILL_ONE",
	"USING_SKILL_TWO",
	"USING_SKILL_THREE",
	"USING_SKILL_ULTIMATE"
]

var direction: float = 0.0
var last_direction: float = 1.0
var target_jump_height: float = 0.0

var base_hitbox_position: Vector2 = Vector2.ZERO
var base_hitbox_size: Vector2 = Vector2.ZERO

var can_jump: bool = true
var can_basic_attack: bool = true
var can_skill_one: bool = true
var can_skill_two: bool = true
var can_skill_three: bool = true
var can_skill_ultimate: bool = true

var jumping: bool = false
var using_basic_attack: bool = false
var using_skill_one: bool = false
var using_skill_two: bool = false
var using_skill_three: bool = false
var using_skill_ultimate: bool = false

var health: float = 0.0
var movement_speed: float = 0.0
var jump_velocity: float = 0.0
var crouch_speed: float = 0.0


@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var jump_cooldown_timer: Timer = $Timers/JumpCooldownTimer
@onready var basic_attack_cooldown_timer: Timer = $Timers/BasicAttackCooldownTimer
@onready var skill_one_cooldown_timer: Timer = $Timers/SkillOneCooldownTimer
@onready var skill_two_cooldown_timer: Timer = $Timers/SkillTwoCooldownTimer
@onready var skill_three_cooldown_timer: Timer = $Timers/SkillThreeCooldownTimer
@onready var skill_ultimate_cooldown_timer: Timer = $Timers/SkillUltimateCooldownTimer
@onready var hitbox: CollisionShape2D = $Hitbox/Collision


func _ready() -> void:
	anim_sprite.play("idle")
	_setup()


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	direction = Input.get_axis("move_left", "move_right")
	last_direction = direction if direction != 0.0 else last_direction

	can_jump = jump_cooldown_timer.is_stopped() and is_on_floor()
	can_basic_attack = basic_attack_cooldown_timer.is_stopped()
	can_skill_one = skill_one_cooldown_timer.is_stopped()
	can_skill_two = skill_two_cooldown_timer.is_stopped()
	can_skill_three = skill_three_cooldown_timer.is_stopped()
	can_skill_ultimate = skill_ultimate_cooldown_timer.is_stopped()


@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	# Process state
	match current_state:
		State.IDLE: pass
		State.MOVING: _process_moving(movement_speed)
		State.JUMPED: _process_jumped()
		State.JUMPING: _process_jumping()
		State.FALLING: _process_falling(GRAVITY_CLAMP)
		State.CROUCHING: _process_crouching()
		State.USE_BASIC_ATTACK: _process_basic_attack()
		State.USE_SKILL_ONE: _process_skill_one()
		State.USE_SKILL_TWO: _process_skill_two()
		State.USE_SKILL_THREE: _process_skill_three()
		State.USE_SKILL_ULTIMATE: _process_skill_ultimate()
		State.MOVING_WHILE_FALLING: _process_moving_while_falling()
		State.MOVING_WHILE_CROUCHING: _process_moving_while_crouching()
		State.USING_BASIC_ATTACK: _process_using_basic_attack()
		State.USING_SKILL_ONE: _process_using_skill_one()
		State.USING_SKILL_TWO: _process_using_skill_two()
		State.USING_SKILL_THREE: _process_using_skill_three()
		State.USING_SKILL_ULTIMATE: _process_using_skill_ultimate()

	# Transition state
	if Input.is_action_pressed("ultimate") and can_skill_ultimate:
		current_state = State.USE_SKILL_ULTIMATE
	elif Input.is_action_pressed("skill_three") and can_skill_three:
		current_state = State.USE_SKILL_THREE
	elif Input.is_action_pressed("skill_two") and can_skill_two:
		current_state = State.USE_SKILL_TWO
	elif Input.is_action_pressed("skill_one") and can_skill_one:
		current_state = State.USE_SKILL_ONE
	elif Input.is_action_just_pressed("basic_attack") and can_basic_attack:
		current_state = State.USE_BASIC_ATTACK
	elif Input.is_action_pressed("jump") and can_jump:
		current_state = State.JUMPED
	elif Input.is_action_pressed("crouch") and direction != 0.0:
		current_state = State.MOVING_WHILE_CROUCHING
	elif direction != 0.0 and jumping:
		current_state = State.MOVING_WHILE_JUMPING
	elif direction != 0.0 and not is_on_floor():
		current_state = State.MOVING_WHILE_FALLING
	elif Input.is_action_pressed("crouch"):
		current_state = State.CROUCHING
	elif direction != 0.0:
		current_state = State.MOVING
	elif jumping:
		current_state = State.JUMPING
	elif not is_on_floor():
		current_state = State.FALLING
	else:
		current_state = State.IDLE

	_handle_animation()

	# Debug
	if current_state != State.IDLE:
		print("CURRENT STATE: ", str(animations[current_state]))

	move_and_slide()


######################################################################
###                             STATES                             ###
######################################################################


func _process_moving(speed: float) -> void:
	_flip_character()
	velocity.x = direction * speed


func _process_jumped() -> void:
	can_jump = false
	jump_cooldown_timer.start()
	jumping = true
	target_jump_height = -jump_velocity


func _process_jumping() -> void:
	print("v: %.2f\t\tt: %.2f" % [velocity.y, target_jump_height])
	print("v <= t : ", velocity.y >= target_jump_height)
	if velocity.y >= target_jump_height:
		velocity.y -= get_gravity().y * 0.9
	else:
		jumping = false


func _process_falling(gravity_multiplier: float) -> void:
	velocity.y += get_gravity().y * gravity_multiplier


func _process_crouching() -> void:
	if is_on_floor():
		pass # crouch logic, maybe shorten collision
	else:
		_process_falling(GRAVITY_CLAMP * 5.0) # Faster fall when "crouching"


func _process_moving_while_jumping() -> void:
	_process_moving(movement_speed)
	_process_jumping()


func _process_moving_while_falling() -> void:
	_process_moving(movement_speed)
	_process_falling(GRAVITY_CLAMP)


func _process_moving_while_crouching() -> void:
	_process_moving(movement_speed)
	_process_crouching()


func _process_basic_attack() -> void:
	can_basic_attack = false
	_enable_hitbox()
	current_state = State.USING_BASIC_ATTACK


func _process_skill_one() -> void:
	can_skill_one = false
	_enable_hitbox()
	current_state = State.USING_SKILL_ONE


func _process_skill_two() -> void:
	can_skill_two = false
	_enable_hitbox()
	current_state = State.USING_SKILL_TWO


func _process_skill_three() -> void:
	can_skill_three = false
	_enable_hitbox()
	current_state = State.USING_SKILL_THREE


func _process_skill_ultimate() -> void:
	can_skill_ultimate = false
	_enable_hitbox()
	current_state = State.USING_SKILL_ULTIMATE


func _process_using_basic_attack() -> void:
	# basic attack...
	# done basic attack
	basic_attack_cooldown_timer.start()


func _process_using_skill_one() -> void:
	# skill 1...
	# done skill 1
	skill_one_cooldown_timer.start()
	_disable_hitbox() # move to subclass character


func _process_using_skill_two() -> void:
	# skill 2...
	# done skill 2
	skill_two_cooldown_timer.start()
	_disable_hitbox() # move to subclass character


func _process_using_skill_three() -> void:
	# skill 3...
	# skill 3
	skill_three_cooldown_timer.start()
	_disable_hitbox() # move to subclass character


func _process_using_skill_ultimate() -> void:
	# ult...
	# done ult
	skill_ultimate_cooldown_timer.start()
	_disable_hitbox() # move to subclass character


######################################################################
###                            PRIVATE                             ###
######################################################################


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

	basic_attack_cooldown_timer.wait_time = basic_attack_cooldown
	skill_one_cooldown_timer.wait_time = skill_one_cooldown
	skill_two_cooldown_timer.wait_time = skill_two_cooldown
	skill_three_cooldown_timer.wait_time = skill_three_cooldown
	skill_ultimate_cooldown_timer.wait_time = ultimate_cooldown

	basic_attack_cooldown_timer.one_shot = true
	skill_one_cooldown_timer.one_shot = true
	skill_two_cooldown_timer.one_shot = true
	skill_three_cooldown_timer.one_shot = true
	skill_ultimate_cooldown_timer.one_shot = true

	if not basic_attack_cooldown_timer.is_connected("timeout", Callable(self, "_on_basic_attack_timer_timeout")):
		basic_attack_cooldown_timer.connect("timeout", Callable(self, "_on_basic_attack_timer_timeout"))
	if not skill_one_cooldown_timer.is_connected("timeout", Callable(self, "_on_skill_one_timer_timeout")):
		skill_one_cooldown_timer.connect("timeout", Callable(self, "_on_skill_one_timer_timeout"))
	if not skill_two_cooldown_timer.is_connected("timeout", Callable(self, "_on_skill_two_timer_timeout")):
		skill_two_cooldown_timer.connect("timeout", Callable(self, "_on_skill_two_timer_timeout"))
	if not skill_three_cooldown_timer.is_connected("timeout", Callable(self, "_on_skill_three_timer_timeout")):
		skill_three_cooldown_timer.connect("timeout", Callable(self, "_on_skill_three_timer_timeout"))
	if not skill_ultimate_cooldown_timer.is_connected("timeout", Callable(self, "_on_ultimate_timer_timeout")):
		skill_ultimate_cooldown_timer.connect("timeout", Callable(self, "_on_ultimate_timer_timeout"))


func _enable_hitbox() -> void:
	hitbox.disabled = false


func _disable_hitbox() -> void:
	hitbox.disabled = true


######################################################################
###                             PUBLIC                             ###
######################################################################


func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0.0:
		# die
		pass


func wait(time: float) -> void:
	await get_tree().create_timer(time).timeout


######################################################################
###                             TIMERS                             ###
######################################################################


func _on_jump_cooldown_timer_timeout() -> void:
	can_jump = true


func _on_basic_attack_timer_timeout() -> void:
	#print("bayes")
	can_basic_attack = true
	_disable_hitbox()


func _on_skill_one_timer_timeout() -> void:
	#print("s1yes")
	can_skill_one = true
	_disable_hitbox()


func _on_skill_two_timer_timeout() -> void:
	#print("s2yes")
	can_skill_two = true
	_disable_hitbox()


func _on_skill_three_timer_timeout() -> void:
	#print("s3yes")
	can_skill_three = true
	_disable_hitbox()


func _on_ultimate_timer_timeout() -> void:
	#print("ultyes")
	can_skill_ultimate = true
	_disable_hitbox()
