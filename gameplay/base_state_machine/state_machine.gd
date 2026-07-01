class_name StateMachine extends Node


@export var initial_state : State = null


var states : Dictionary[String, State] = {}

var current_state : State = null :
	set(value):
		character_parent.play_animation_according_to_state(value.name.to_lower())

var character_parent : Character :
	get:
		return get_parent() as Character

var facing_direction : float = 0.0


func _ready() -> void:
	_init_states()


func _process(_delta : float) -> void:
	if current_state != null:
		current_state.process()


func _physics_process(_delta : float) -> void:
	if current_state != null:
		current_state.physics_process()


func _init_states() -> void:
	# Add state nodes to local "states" dictionary
	var fsm_children : Array = Util.get_descendants(self)
	for child in fsm_children:
		if child is State:
			states[child.name.to_lower()] = child
			child.connect("state_changed", _on_state_changed)

	# Set initial state
	if initial_state != null:
		print("yep initial_state is not null")
		current_state = initial_state
		current_state.enter()
	print("current_state: ", current_state)


func _on_state_changed(before : State, new_state_name : String) -> void:
	if current_state != before:
		return

	var new_state : State = states.get(new_state_name.to_lower())
	if new_state == null:
		push_error("State doesn't exist: ", new_state_name)
		return

	current_state.exit()
	new_state.enter()

	print(current_state.name, " -> ", new_state.name)

	current_state = new_state
