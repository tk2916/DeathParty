extends CharacterBody3D

@onready var model : Node3D = %PlayerModel
@onready var animation_tree : AnimationTree = %AnimationTree
@onready var previous_position : Vector3 = global_position
@onready var footstep_sounds : FmodEventEmitter3D = $FootstepSounds

@export var gravity : float = 2.0
@export var player_speed : float = 2.0
@export var jump_power : float = 12.0
@export var horizontal_offset : float = 1.75

@export var player_camera_location : Node3D

var player_velocity : Vector3 = Vector3.ZERO
var original_camera_position : Vector3 = Vector3.ZERO

var facing: int = 0
var movement_direction: int = 0
var prev_movement_direction: int = 0

# animation enum and vars
enum AnimationState {IDLE, WALK, TURN} # TURN currently unused
var blend_speed : float = 5
var walk_blend : float = 0
var current_animation : AnimationState = AnimationState.IDLE

# footstep sound vars
var is_moving : bool = false
var was_moving : bool = false
var prev_pos : Vector3 = position
var stride_length : float = 1
var distance_since_step : float = 0

func _ready() -> void:
	original_camera_position = player_camera_location.position

func _physics_process(_delta: float) -> void:
	player_camera_location.position = original_camera_position
	
	# Direction of movement in the X axis
	# Also, adding horizontal camera offset
	var movement_direction_x: int = 0
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"):
		pass
	elif Input.is_action_pressed("move_left"):
		facing = -1
		movement_direction_x = -1
		player_camera_location.position.x -= horizontal_offset
	elif  Input.is_action_pressed("move_right"):
		facing = 1
		movement_direction_x = 1
		player_camera_location.position.x += horizontal_offset
	
	# Z axis movement
	var movement_direction_z: int = 0
	if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_down"):
		pass
	elif Input.is_action_pressed("move_up"):
		movement_direction_z = 1
	elif Input.is_action_pressed("move_down"):
		movement_direction_z = -1
	# Jump
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			player_velocity.y = jump_power
		else:
			# This line only exists to make slopes work after the player jumps
			player_velocity.y = 0
	
	movement_direction = movement_direction_x
	
	# Move on x axis
	player_velocity.x = movement_direction_x * player_speed
	player_velocity.z = movement_direction_z * player_speed
	
	# Fall
	if not is_on_floor():
		player_velocity.y -= gravity
	
	velocity = player_velocity * global_transform.basis * Basis.FLIP_Z

	handle_animations(_delta)

	rotate_model(_delta)

	handle_footstep_sounds()

	move_and_slide()
	
	# If position changed, emit position
	if(global_position != previous_position):
		GlobalPlayerScript.player_moved.emit(global_position)
		previous_position = global_position


func handle_animations(delta: float) -> void:
	# set anim state to IDLE if player not moving
	if movement_direction == 0:
		current_animation = AnimationState.IDLE

	# set anim state to WALK if player moving
	elif movement_direction != 0:
		current_animation = AnimationState.WALK

	# interpolate blend between IDLE and WALK anim states
	match current_animation:
		AnimationState.IDLE:
			walk_blend = lerpf(walk_blend, 0, blend_speed * delta)
		AnimationState.WALK:
			walk_blend = lerpf(walk_blend, 1, blend_speed * delta)
	
	animation_tree["parameters/Walk Blend/blend_amount"] = walk_blend

	#prev_movement_direction = movement_direction


func rotate_model(delta: float) -> void:
	# rotate model slightly towards camera while idle
	if current_animation == AnimationState.IDLE:
		if facing == -1:
			model.rotation.y = lerp_angle(model.rotation.y, -PI/5, blend_speed * delta)
		if facing == 1:
			model.rotation.y = lerp_angle(model.rotation.y, PI/5, blend_speed * delta)

	# rotate model left and right while walking
	if current_animation == AnimationState.WALK:
		if facing == -1:
			model.rotation.y = lerp_angle(model.rotation.y, -PI/2, blend_speed * delta)
		if facing == 1:
			model.rotation.y = lerp_angle(model.rotation.y, PI/2, blend_speed * delta)


func handle_footstep_sounds() -> void:
	# plays footsteps as the node moves based on distance travelled on floor

	# once we have animated 3D models, this could probably be replaced with
	# a trigger whenever the model's foot collides with the floor 
	if is_on_floor():
		# store movement state from previous frame and reset current state
		was_moving = is_moving
		is_moving = false

		# check if player is holding a move input
		for action in InputMap.get_actions():
			if action.begins_with("move_") and Input.is_action_pressed(action):
				is_moving = true

		if is_moving:
			# if started moving this frame, start step cycle
			# at halfway point (this is better than just playing a sound
			# for the first step immediately cos it prevents spam)
			if not was_moving:
				distance_since_step = stride_length / 2

			# get distance travelled since last frame and add it to
			# total distance travelled since last step
			distance_since_step += position.distance_to(prev_pos)

			# if total distance since last step exceeds stride length,
			# play step sound and reset cycle
			if distance_since_step >= stride_length:
				footstep_sounds.play()
				distance_since_step = 0

		# if player stopped moving this frame, reset cycle
		if was_moving and not is_moving:
			distance_since_step = 0

		# store current position for next frame
		prev_pos = position
