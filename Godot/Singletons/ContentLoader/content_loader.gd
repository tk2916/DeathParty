extends Node

var main_camera : MainCamera

var player : Player
var player_file : PackedScene = preload("res://Entities/player.tscn")
var player_aabb : AABB
var player_spawn_pos : Vector3

var scene_data_dict : Dictionary[String, SceneData] = {}
var quadrant_grids : Dictionary[String, Vector3] = {
	"PartyRoom" = Vector3(5,1,5),
	"Entrance" = Vector3(1,1,1),
	"Bathroom" = Vector3(1,1,1),
	"Library" = Vector3(1,1,1),
	"Basement" = Vector3(1,1,1),
	"Kitchen" = Vector3(1,1,1),
	
}

@onready var tree : SceneTree = get_tree()
@onready var main_node : Node3D = tree.root.get_node_or_null("Main")

var loaded_scenes : Array[SceneData]
@onready var loadable_scenes_size : int = tree.get_nodes_in_group("loadable_scene").size()
var og_scene : String
var loading_screen : ColorRect

var loaded : bool = false
signal finished_loading
signal added_scene

func _ready() -> void:
	print(tree.get_nodes_in_group("loadable_scene"))
	if main_node:
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
	tween.tween_property(loading_screen, "modulate:a", 1, .2)
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
		var scene_data : SceneData = scene_data_dict[scene_name]
		for loader : SceneLoaderData in scene_data.get_all_scene_loaders():
			var target_scene_name : String = loader.target_scene_name
			#print("From ", scene_name, ": ", target_scene_name, " loader: ", loader.name)
			if scene_data_dict.has(target_scene_name) and scene_data_dict[target_scene_name].main_teleport_point == Vector3(-1,-1,-1):
				scene_data_dict[target_scene_name].set_main_teleport(loader.name, loader.teleport_pos)

func store_scene_info(node : Node3D) -> void:
	var filepath : String = node.scene_file_path
	
	var node_name : String = node.name
	var node_file : PackedScene = load(filepath)
	var node_instance : Node3D = node
	var quadrant_grid : Vector3
	if quadrant_grids.has(node_name):
		quadrant_grid = quadrant_grids[node_name]
	else:
		quadrant_grid = Vector3(1,1,1)
	var new_scene_data : SceneData = SceneData.new(
		node_name, 
		node_file, 
		node_instance,
		main_node,
		quadrant_grid,
		)
	scene_data_dict[node_name] = new_scene_data
	
	if new_scene_data.scene_aabb.intersects(player_aabb): #check intersection
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
	print("Creating player: ", player)
	
func on_node_added(node:Node) -> void:
	if loaded or !(node is Node3D): return
	if node.is_in_group("player"):
		print("Player added")
		fade_loading_screen_in()
		player = node
		player_aabb = calculate_node_aabb(node)
		player_spawn_pos = node.global_position
		main_node.remove_child(node)
		#node.queue_free()
		print("Removed player node")
	elif node.is_in_group("loadable_scene"):
		print("Found loadable scene: ", node.name)
		node.ready.connect(store_scene_info.bind(node))

func update_player_aabb():
	player_aabb = calculate_node_aabb(player)

func calculate_node_aabb(node3d : Node3D) -> AABB:
	var visual_nodes : Array[Node] = node3d.find_children("*", "VisualInstance3D", true, false)
	assert(!visual_nodes.is_empty(), "There are no visual nodes in this scene!")
	var aabb : AABB = visual_nodes[0].global_transform * visual_nodes[0].get_aabb()
	for node : Node in visual_nodes:
		if (node == visual_nodes[0] or 
		!(node is VisualInstance3D) or 
		(node is Light3D) or
		node.name == "PlayerCameraLocation" or
		node.name == "Lights"
		): continue
		var node_aabb : AABB = node.get_aabb()
		var global_aabb : AABB = node.global_transform * node_aabb
		aabb = aabb.merge(global_aabb)
		
	return aabb

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
	if loaded_scenes.size() > 0 && loaded_scenes.front().name == scene_name: 
		return loaded_scenes.front().instance
	
	var scene_data : SceneData = scene_data_dict[scene_name]
	print(1)
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
	var old_loaded_scene : SceneData = loaded_scenes.pop_back()
	old_loaded_scene.offload()

func scene_loader_load(scene_name : String, new_position : Vector3) -> void:
	fade_loading_screen_in().finished.connect(func():
		load_scene(scene_name).ready.connect(func():
			print("Teleporting player to ", scene_name)
			GlobalCameraScript.move_camera_jump.emit()
			player.global_position = new_position
			offload_old_scenes()
			await tree.create_timer(1).timeout
			fade_loading_screen_out()
			await GlobalCameraScript.finished_moving
			GlobalCameraScript.move_camera_smooth.emit()
		)
	)

func direct_teleport_player(scene_name : String) -> void:
	var target_pos : Vector3 = scene_data_dict[scene_name].main_teleport_point
	assert(target_pos != Vector3(-1,-1,-1), "" + scene_name + " doesn't have a teleport point assigned. Check that all your SceneLoaders are following the naming convention 'SceneLoader_<scene name (case-sensitive)>'!")
	scene_loader_load(scene_name, target_pos)
