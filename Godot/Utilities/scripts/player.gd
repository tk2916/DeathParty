class_name Player extends CharacterBody3D

@onready var model : Node3D = %PlayerModel
@onready var animation_tree : AnimationTree = %AnimationTree
@onready var previous_position : Vector3 = global_position
@onready var quadrant_position : Vector3 = global_position
@onready var footstep_sounds : FmodEventEmitter3D = $FootstepSounds
@onready var spawn_position : Vector3 = global_position

@export var player_speed := 2.3
@export var horizontal_offset : float = 1.3

@export var player_camera_location : Node3D

var player_velocity : Vector3 = Vector3.ZERO
var original_camera_position : Vector3 = Vector3.ZERO

var facing: int = 0
var movement_direction: int = 0
var prev_movement_direction: int = 0

# animation enum and vars
enum AnimationState {IDLE, WALK, TURN} # TURN currently unused
var blend_speed : float = 8
var walk_blend : float = 0
var current_animation : AnimationState = AnimationState.IDLE

var movement_disabled : bool = false

func _enter_tree() -> void:
	original_camera_position = player_camera_location.position


func _physics_process(delta : float) -> void:
	if DialogueSystem.in_dialogue or GuiSystem.in_gui or movement_disabled:
		player_velocity = Vector3.ZERO
		handle_animations(delta)
		return
		
	player_camera_location.position = original_camera_position

	# Direction of movement in the X axis
	# Also, adding horizontal camera offset
	var movement_direction_x: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"):
		pass
	elif Input.is_action_pressed("move_left"):
		facing = -1
		movement_direction_x = -basis.x
		player_camera_location.position.x -= horizontal_offset
	elif  Input.is_action_pressed("move_right"):
		facing = 1
		movement_direction_x = basis.x
		player_camera_location.position.x += horizontal_offset

	# Z axis movement
	var movement_direction_z: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_down"):
		pass
	elif Input.is_action_pressed("move_up"):
		movement_direction_z = -basis.z
	elif Input.is_action_pressed("move_down"):
		movement_direction_z = basis.z

	# Move on x axis
	player_velocity = movement_direction_x + movement_direction_z
	player_velocity = player_velocity.normalized() * player_speed

	# Fall
	if not is_on_floor():
		player_velocity.y += get_gravity().y

	velocity = player_velocity

	handle_animations(delta)

	rotate_model(delta)

	move_and_slide()

	# If position changed, emit position
	if(global_position != previous_position):
		GlobalPlayerScript.player_moved.emit(global_position)
		previous_position = global_position
		var quad_dist : float = global_position.distance_squared_to(quadrant_position)
		#print("quad dist: ", quad_dist)
		if (quad_dist > 10):
			#only update active quadrants once player has moved > sqrt(10) units
			GlobalPlayerScript.update_quadrants.emit()
			quadrant_position = global_position


func handle_animations(delta: float) -> void:
	# set anim state to IDLE if player not moving
	if player_velocity == Vector3.ZERO:
		current_animation = AnimationState.IDLE

	# set anim state to WALK if player moving
	elif player_velocity != Vector3.ZERO:
		current_animation = AnimationState.WALK

	# interpolate blend between IDLE and WALK anim states
	match current_animation:
		AnimationState.IDLE:
			walk_blend = lerpf(walk_blend, 0, blend_speed * delta)
		AnimationState.WALK:
			walk_blend = lerpf(walk_blend, 1, blend_speed * delta)

	animation_tree["parameters/Walk Blend/blend_amount"] = walk_blend

	# adjust speed of walk animation based on player_speed

	# NOTE: 2.0 is the player_speed that roughly matches the animation,
	# so we scale based on that
	if player_velocity != Vector3.ZERO:
		animation_tree.set("parameters/TimeScale/scale", player_speed / 2.0)
	elif player_velocity == Vector3.ZERO:
		animation_tree.set("parameters/TimeScale/scale", 1.0)

	#prev_movement_direction = movement_direction


func rotate_model(delta: float) -> void:
	# rotate model slightly towards camera while idle
	if current_animation == AnimationState.IDLE:
		if facing == -1:
			model.rotation.y = lerp_angle(model.rotation.y, -PI/5, blend_speed * delta)
		if facing == 1:
			model.rotation.y = lerp_angle(model.rotation.y, PI/5, blend_speed * delta)

	# rotate while walking
	if current_animation == AnimationState.WALK:
		model.rotation.y = lerp_angle(model.rotation.y, basis.z.signed_angle_to(velocity, basis.y), blend_speed * delta)


func reset_position():
	global_position = spawn_position
	##ALSO MAKE IT SO IT LOADS THE ORIGINAL SCENES
	ContentLoader.reset()


func _on_world_boundary_body_entered(body : Node3D) -> void:
	if body == self:
		print("player out of bounds, resetting position . . .")
		reset_position()
