class_name SceneLoaderData extends SceneObject

var collision_shape_dimensions : Vector3
var teleport_pos : Vector3
var target_scene_name : String

func _init(
	_scene : LoadableScene,
	_instance : Node3D,
	_parent_node : GameObject,
) -> void:
	super(
	_scene, 
	_instance,
	_parent_node
	)
	var collision_shape : CollisionShape3D = instance.get_node("CollisionShape3D") 
	collision_shape_dimensions = collision_shape.position
	teleport_pos = instance.teleport_pos#.get_node("TeleportPoint").global_position#_teleport_pos
	target_scene_name = name.substr(12)

func load_in(max_objects_per_frame : int = 10000) -> Node3D:
	await super()
	var collision_shape : CollisionShape3D = instance.get_node("CollisionShape3D") 
	collision_shape.position = collision_shape_dimensions
	instance.teleport_pos = teleport_pos
	return instance
