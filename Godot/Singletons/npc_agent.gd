extends CharacterBody3D
class_name NPCAgent

@export var model: Node3D
@export var animation_tree: AnimationTree

@onready var default_map_rid: RID = get_world_3d().get_navigation_map()

## Animation variables
enum ANIMATION_STATE {IDLE, WALK, TURN}
var current_animation: ANIMATION_STATE = ANIMATION_STATE.IDLE
var blend_speed: float = 8.0
var walk_blend: float = 0.0

## Movement path variables
var path_point_margin: float = 0.5
var current_path_index: int = 0
var current_path_point: Vector3
var current_path: PackedVector3Array


## Just a shortcut for the NavigationServer function call
func get_random_point(map: RID, navigation_layers: int, uniformly: bool) -> Vector3:
	return NavigationServer3D.map_get_random_point(map, navigation_layers, uniformly)


## Create a path to the desired destination
func set_movement_target(destination: Vector3, navigation_layers: int, map: RID = default_map_rid) -> void:
	var start_position: Vector3 = global_transform.origin
	## Randomize if NPC moves optimally for variation
	var optimize_path: bool = RandomNumberGenerator.new().randi_range(0, 1) == 1
	
	current_path = NavigationServer3D.map_get_path(map, start_position, destination, optimize_path, navigation_layers)
	
	if not current_path.is_empty():
		current_path_index = 0
		current_path_point = current_path[0]


## Create a path to a random destination
func set_movement_target_random(navigation_layers: int, map: RID = default_map_rid, uniformly: bool = false) -> void:
	var random_location: Vector3 = NavigationServer3D.map_get_random_point(map, navigation_layers, uniformly)
	set_movement_target(random_location, navigation_layers, map)


## Move agent along current path
