extends CharacterBody3D
class_name NPCAgent

@export var model: Node3D
@export var animation_tree: AnimationTree
@export var node_path: Path3D

@onready var default_map_rid: RID = get_world_3d().get_navigation_map()

## Animation variables
enum ANIMATION_STATE {IDLE, WALK, TURN}
var current_animation: ANIMATION_STATE = ANIMATION_STATE.IDLE
var blend_speed: float = 8.0
var walk_blend: float = 0.0

## Movement path variables
var path_point_margin: float = 1
var current_path_index: int = 0
var current_path_point: Vector3
var current_path: PackedVector3Array


## Create a path to the desired destination
func set_movement_target(destination: Vector3, navigation_layers: int, map: RID = default_map_rid) -> void:
	var start_position: Vector3 = global_transform.origin
	## Randomize if NPC moves optimally for variation
	var optimize_path: bool = RandomNumberGenerator.new().randi_range(0, 1) == 1
	#var optimize_path: bool = true
	
	current_path = NavigationServer3D.map_get_path(map, start_position, destination, optimize_path, navigation_layers)
	
	
	if not current_path.is_empty():
		current_path_index = 0
		current_path_point = current_path[0]
		
		var curve: Curve3D = Curve3D.new()
		for vertex: Vector3 in current_path:
			curve.add_point(vertex)
		node_path.set_curve(curve)


## Create a path to a random destination
func set_movement_target_random(navigation_layers: int, map: RID = default_map_rid, uniformly: bool = false) -> void:
	var random_location: Vector3 = NavigationServer3D.map_get_random_point(map, navigation_layers, uniformly)
	set_movement_target(random_location, navigation_layers, map)


func wander(movement_speed: float, navigation_layers: int, delta: float = 0, map: RID = default_map_rid, uniformly: bool = false) -> void:
	if not current_path.is_empty():
		move_npc(movement_speed, delta)
		return
	animate_npc(delta)
	
	## physics_process runs 60 times per second
	## randi from 1-200 should be a .005 chance to get '1' -> .5% chance to decide to move every frame
	## 1 - ((1-.005)^60) ~= 26% chance to decide to move every second while idle, I think?
	var random_number: int = RandomNumberGenerator.new().randi_range(1, 200)
	if random_number != 1:
		return
	
	set_movement_target_random(navigation_layers)

## Move agent along current path
func move_npc(movement_speed: float, delta: float = 0) -> void:
	if current_path.is_empty():
		return
	
	if global_transform.origin.distance_to(current_path_point) <= path_point_margin:
		current_path_index += 1
		if current_path_index >= current_path.size():
			current_path = []
			current_path_index = 0
			current_path_point = global_transform.origin
			velocity = Vector3.ZERO
			return
	
	current_path_point = current_path[current_path_index]
	var new_velocity: Vector3 = global_transform.origin.direction_to(current_path_point) * movement_speed
	# Fall
	if not is_on_floor():
		new_velocity.y += get_gravity().y
	
	velocity = new_velocity
	move_and_slide()
	apply_floor_snap() # Keep NPC on ground
	animate_npc(delta)


## play NPC animations
func animate_npc(delta: float) -> void:
	if not model or not animation_tree:
		return
	
	# set anim state to IDLE if not moving
	if velocity == Vector3.ZERO:
		current_animation = ANIMATION_STATE.IDLE

	# set anim state to WALK if moving
	elif velocity != Vector3.ZERO:
		current_animation = ANIMATION_STATE.WALK

	# interpolate blend between IDLE and WALK anim states
	match current_animation:
		ANIMATION_STATE.IDLE:
			walk_blend = lerpf(walk_blend, 0, blend_speed * delta)
		ANIMATION_STATE.WALK:
			walk_blend = lerpf(walk_blend, 1, blend_speed * delta)
	
	animation_tree["parameters/Walk Blend/blend_amount"] = walk_blend
	
	# Rotate model
	if current_animation == ANIMATION_STATE.WALK:
		model.rotation.y = lerp_angle(model.rotation.y, basis.z.signed_angle_to(velocity, basis.y), blend_speed * delta)
