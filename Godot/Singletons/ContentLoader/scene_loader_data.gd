class_name SceneLoaderData extends SceneObject

#save properties
var teleport_point : TeleportPointData
var play_door_sound : bool
var offload_delay : float

var target_scene_name : String
var local_spawn_point : int

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
	scene.scene_loader_dict[name] = self

func load_in() -> Node3D:
	await super()
	loader = instance as SceneLoader
	load_properties()
	return loader

func set_teleport_point():
	#Called after all scenes have loaded in
	var target_scene : LoadableScene = ContentLoader.get_scene(target_scene_name)
	
	if local_spawn_point < target_scene.teleport_points.size():
		teleport_point = target_scene.teleport_points[local_spawn_point]
	print("Checking teleport ", target_scene.name, " for ", local_spawn_point, " | ", teleport_point)
	if loader and teleport_point:
		loader.teleport_point = teleport_point
		print("Set teleport: ", teleport_point)

func save_properties():
	play_door_sound = loader.play_door_sound
	offload_delay = loader.offload_delay
	
	local_spawn_point = loader.local_spawn_point
	target_scene_name = loader.target_scene

func load_properties():
	loader.teleport_point = teleport_point
	loader.play_door_sound = play_door_sound
	loader.offload_delay = offload_delay
