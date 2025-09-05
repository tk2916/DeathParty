class_name SceneLoaderData extends SceneObject

#save properties
var teleport_point : TeleportPointData
var play_door_sound : bool
var popup_transform : Transform3D
var popup_texture : CompressedTexture2D

var target_scene_name : String
var local_spawn_point : Globals.SPAWN_OPTIONS

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

func set_teleport_point() -> void:
	#Called after all scenes have loaded in
	var target_scene : LoadableScene = ContentLoader.get_scene(target_scene_name)
	
	if target_scene.teleport_points.has(local_spawn_point):
		teleport_point = target_scene.teleport_points[local_spawn_point]
	print("Checking teleport ", target_scene.name, " for ", local_spawn_point, " | ", teleport_point)
	if loader and teleport_point:
		loader.teleport_point = teleport_point
		print("Set teleport: ", teleport_point)

func save_properties() -> void:
	play_door_sound = loader.play_door_sound
	
	local_spawn_point = loader.local_spawn_point
	target_scene_name = loader.target_scene
	if loader.popup:
		var popup : Sprite3D= loader.popup as Sprite3D
		popup_transform = popup.transform
		popup_texture = popup.texture

func load_properties() -> void:
	loader.teleport_point = teleport_point
	loader.play_door_sound = play_door_sound
	if loader.popup:
		var popup : Sprite3D= loader.popup as Sprite3D
		popup.transform = popup_transform
		popup.texture = popup_texture
