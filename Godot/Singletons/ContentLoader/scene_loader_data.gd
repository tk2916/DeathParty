class_name SceneLoaderData extends SceneObject

#save properties (these are set in main)
var collision_shape_dimensions : Vector3
var teleport_pos : Vector3
var scene_going_right : String
var scene_going_left : String
var play_door_sound : bool
var offload_delay : float

var target_scene_name : String
var loader : SceneLoader

func _init(
	_scene : LoadableScene,
	_instance : SceneLoader,
	_parent_node : GameObject,
) -> void:
	super(
	_scene, 
	_instance,
	_parent_node
	)
	loader = instance as SceneLoader
	save_properties()
	target_scene_name = name.substr(12)

func load_in(max_objects_per_frame : int = 10000) -> Node3D:
	await super()
	loader = instance as SceneLoader
	load_properties()
	return instance

func save_properties():
	var collision_shape : CollisionShape3D = loader.get_node("CollisionShape3D") 
	collision_shape_dimensions = collision_shape.position
	teleport_pos = loader.teleport_pos
	scene_going_left = loader.scene_going_left
	scene_going_right = loader.scene_going_right
	play_door_sound = loader.play_door_sound
	offload_delay = loader.offload_delay

func load_properties():
	var collision_shape : CollisionShape3D = loader.get_node("CollisionShape3D") 
	collision_shape.position = collision_shape_dimensions
	loader.teleport_pos = teleport_pos
	loader.scene_going_left = scene_going_left
	loader.scene_going_right = scene_going_right
	loader.play_door_sound = play_door_sound
	loader.offload_delay = offload_delay
