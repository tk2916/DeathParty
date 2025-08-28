extends Node

var main_camera : MainCamera

var player : Player
var player_file : PackedScene = preload("res://Entities/player.tscn")
var player_aabb : AABB
var player_spawn_pos : Vector3

var scene_teleport_pos : Vector3

var scene_data_dict : Dictionary[String, LoadableScene] = {}
var cell_grids : Dictionary[String, Vector3] = {
	"PartyRoom" = Vector3(5,1,1),
	"Entrance" = Vector3(1,1,1),
	"Bathroom" = Vector3(1,1,1),
	"Bedroom" = Vector3(1,1,1),
	"Library" = Vector3(1,1,1),
	"Basement" = Vector3(1,1,1),
	"Kitchen" = Vector3(1,1,1),
	"Exterior" = Vector3(10,1,10),
}

@onready var tree : SceneTree = get_tree()
@onready var main_node : Node3D = tree.root.get_node_or_null("Main")
var main_node_data : GameObject

var loaded_scenes : Array[LoadableScene]
@onready var loadable_scenes_size : int = tree.get_nodes_in_group("loadable_scene").size()
var og_scene : String = ""
var active_scene : String = ""
var loading_screen : ColorRect

var loaded : bool = false
signal finished_loading
signal added_scene

func _ready() -> void:
	print(tree.get_nodes_in_group("loadable_scene"))
	if main_node:
		main_node_data = GameObject.new(main_node)
		main_node.ready.connect(load_player)
		added_scene.connect(find_room_teleport_points)
		
		main_camera = main_node.get_node("MainCamera")
		loading_screen = main_node.get_node("CanvasLayer/LoadingScreen")
		loading_screen.visible = true
		for node in main_node.get_children():
			on_node_added(node)
			
	tree.node_added.connect(on_node_added)

func fade_loading_screen_in(fadeout_delay : float = 0) -> Tween:
	var tween : Tween = tree.create_tween()
	tween.tween_property(loading_screen, "modulate:a", 0, .2)
	if fadeout_delay > 0:
		tween.tween_callback(fade_loading_screen_out.bind(fadeout_delay))
	return tween
	
func fade_loading_screen_out(fadeout_delay : float = 0) -> Tween:
	if is_instance_valid(player) and player.is_inside_tree():
		player.movement_disabled = true
		await tree.create_timer(fadeout_delay).timeout
		player.movement_disabled = false
	var tween : Tween = tree.create_tween()
	tween.tween_property(loading_screen, "modulate:a", 0, 1)
	return tween

func find_room_teleport_points() -> void:
	##Make sure they are all loaded
	if scene_data_dict.keys().size() < loadable_scenes_size: return
	##SET THE TELEPORT POINTS FROM EACH ROOM DEPENDING ON THE SCENE LOADERS
	for scene_name : String in scene_data_dict:
		var scene_data : LoadableScene = scene_data_dict[scene_name]
		for loader : SceneLoaderData in scene_data.get_all_scene_loaders():
			var target_scene_name : String = loader.target_scene_name
			#print("From ", scene_name, ": ", target_scene_name, " loader: ", loader.name)
			if scene_data_dict.has(target_scene_name) and scene_data_dict[target_scene_name].main_teleport_point == Vector3(-1,-1,-1):
				scene_data_dict[target_scene_name].set_main_teleport(loader.name, loader.teleport_pos)

func store_scene_info(node : Node3D) -> void:
	var node_name : String = node.name
	var node_instance : Node3D = node
	var cell_grid : Vector3
	if cell_grids.has(node_name):
		cell_grid = cell_grids[node_name]
	else:
		cell_grid = Vector3(1,1,1)
	var new_scene_data : LoadableScene = LoadableScene.new(
		node_instance,
		main_node_data,
		cell_grid,
		)
	scene_data_dict[node_name] = new_scene_data
	
	if og_scene == "" and new_scene_data.cell_manager.scene_aabb.intersects(player_aabb): #check intersection
		og_scene = node.name
		load_scene(og_scene)
	
	print("Stored scene info for ", node.name, " | ", Time.get_ticks_msec())
	added_scene.emit()

func load_player() -> void:
	loaded = true
	if !is_instance_valid(player):
		player = player_file.instantiate()
		player.global_position = player_spawn_pos
	player.ready.connect(func() -> void:
		fade_loading_screen_out()
		print("Faded screen out")
		finished_loading.emit()
		)
	main_node.add_child.call_deferred(player)
	main_camera.player = player
	
func on_node_added(node:Node) -> void:
	if loaded or !(node is Node3D): return
	if node.is_in_group("player"):
		fade_loading_screen_in()
		player = node
		update_player_aabb()
		player_spawn_pos = node.global_position
		main_node.remove_child(node)
	elif node.is_in_group("loadable_scene"):
		node.ready.connect(store_scene_info.bind(node))

func update_player_aabb() -> void:
	if !player.is_inside_tree(): return
	player_aabb = Utils.calculate_node_aabb(player)

func reset() -> void:
	print("Reset player")
	if main_node == null: return
	fade_loading_screen_in()
	offload_all_scenes()
	load_scene(og_scene)

func load_scene(scene_name:String) -> Node3D:
	print("Attempting to load ", scene_name)
	if main_node == null: return
	if scene_name == "" or !scene_data_dict.has(scene_name): 
		assert(false, "Scene " + scene_name + " doesn't exist/isn't tagged with loadable_scene!")
		return
	#trying to load the currently loaded scene
	if active_scene == scene_name: 
		return loaded_scenes.front().instance
	active_scene = scene_name
	var scene_data : LoadableScene = scene_data_dict[scene_name]
	var scene_instance : Node3D = scene_data.load_in()
	loaded_scenes.push_front(scene_data)
	return scene_instance

func offload_all_scenes() -> void:
	offload_old_scenes()
	offload_old_scene()

func offload_old_scenes() -> void:
	print("Offloading old scenes")
	for n in range(1, loaded_scenes.size()): #skip first one (current scene)
		offload_old_scene()

func offload_old_scene() -> void:
	if main_node == null: return
	var old_loaded_scene : LoadableScene = loaded_scenes.pop_back()
	old_loaded_scene.offload()

func scene_loader_load(scene_name : String, new_position : Vector3) -> void:
	var screen_tween : Tween = fade_loading_screen_in()
	screen_tween.finished.connect(func():
		scene_teleport_pos = new_position
		var scene : Node3D = load_scene(scene_name)
		scene.ready.connect(func():
			#await tree.physics_frame
			print("Teleporting player to ", scene_name)
			player.global_position = new_position
			GlobalCameraScript.move_camera_jump.emit()
			
			offload_old_scenes()
			await tree.create_timer(1).timeout
			fade_loading_screen_out()
			GlobalCameraScript.move_camera_smooth.emit()
		)
	)

func direct_teleport_player(scene_name : String) -> void:
	if scene_name == active_scene: return
	var target_pos : Vector3 = scene_data_dict[scene_name].main_teleport_point
	assert(target_pos != Vector3(-1,-1,-1), "" + scene_name + " doesn't have a teleport point assigned. Check that all your SceneLoaders are following the naming convention 'SceneLoader_<scene name (case-sensitive)>'!")
	scene_loader_load(scene_name, target_pos)
