extends CharacterBody3D

@onready var default_3d_map_rid: RID = get_world_3d().get_navigation_map()
@onready var animation_tree : AnimationTree = %AnimationTree
@export var model : Node3D

var movement_speed: float = 4
var path_point_margin: float = 0.5

var current_path_index: int = 0
var current_path_point: Vector3
var current_path: PackedVector3Array

# animation enum and vars
enum AnimationState {IDLE, WALK, TURN} # TURN currently unused
var blend_speed : float = 8
var walk_blend : float = 0
var current_animation : AnimationState = AnimationState.IDLE

func _ready() -> void:
	setup_npc.call_deferred()

func _physics_process(delta: float) -> void:
	if current_path.is_empty():
		set_movement_target_random()
		return
	
	if global_transform.origin.distance_to(current_path_point) <= path_point_margin:
		current_path_index += 1
		if current_path_index >= current_path.size():
			current_path = []
			current_path_index = 0
			current_path_point = global_transform.origin
			set_movement_target_random()
			return
	
	current_path_point = current_path[current_path_index]
	
	var new_velocity: Vector3 = global_transform.origin.direction_to(current_path_point) * movement_speed
	# Fall
	if not is_on_floor():
		new_velocity.y += get_gravity().y

	velocity = new_velocity
	handle_animations(delta)
	
	move_and_slide()
	apply_floor_snap()
	
func set_movement_target_random() -> void:
	var start_position: Vector3 = global_transform.origin
	var new_destination = NavigationServer3D.map_get_random_point(default_3d_map_rid, 1, false)
	current_path = NavigationServer3D.map_get_path(default_3d_map_rid, start_position, new_destination, true)
	
	if not current_path.is_empty():
		current_path_index = 0
		current_path_point = current_path[0]

func setup_npc() -> void:
	# Need to wait for first physics frame so NavigationServer can sync
	await get_tree().physics_frame
	set_movement_target_random()


func handle_animations(delta: float) -> void:
	# set anim state to IDLE if player not moving
	if velocity == Vector3.ZERO:
		current_animation = AnimationState.IDLE

	# set anim state to WALK if player moving
	elif velocity != Vector3.ZERO:
		current_animation = AnimationState.WALK

	# interpolate blend between IDLE and WALK anim states
	match current_animation:
		AnimationState.IDLE:
			walk_blend = lerpf(walk_blend, 0, blend_speed * delta)
		AnimationState.WALK:
			walk_blend = lerpf(walk_blend, 1, blend_speed * delta)
	
	if model and current_animation == AnimationState.WALK:
		model.rotation.y = lerp_angle(model.rotation.y, basis.z.signed_angle_to(velocity, basis.y), blend_speed * delta)
	
	if animation_tree:
		animation_tree["parameters/Walk Blend/blend_amount"] = walk_blend
