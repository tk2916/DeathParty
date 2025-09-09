extends Node

var main_camera : MainCamera

var player : Player
var player_file : PackedScene = preload("res://Entities/player.tscn")
var player_aabb : AABB
var player_spawn_pos : Vector3

var scene_teleport_pos : Vector3

var scene_data_dict : Dictionary[String, LoadableScene] = {}
var cell_grids : Dictionary[String, Vector3] = {
	#"PartyRoom" = Vector3(5,1,1),
	"PartyRoom" = Vector3(1,1,1),
	#"Exterior" = Vector3(10,1,10),
	"Exterior" = Vector3(1,1,1),
}

@onready var tree : SceneTree = get_tree()
@onready var main_node : Node3D = tree.root.get_node_or_null("Main")
var main_node_data : GameObject

var loaded_scenes : Array[LoadableScene]
@onready var loadable_scenes_size : int = tree.get_nodes_in_group("loadable_scene").size()
var og_scene_name : String = ""
var active_scene_name : String = ""
var loading_screen : ColorRect

var active_scene : LoadableScene:
	get:
		if !scene_data_dict.has(active_scene_name):
			return null
		return scene_data_dict[active_scene_name]

var loaded : bool = false
signal finished_loading
signal added_scene

func _ready() -> void:
	print(tree.get_nodes_in_group("loadable_scene"))
	if main_node:
		main_node_data = GameObject.new(main_node)
		#main_node.ready.connect(load_player)
		added_scene.connect(on_finished_loading_scenes)
		
		main_camera = main_node.get_node("MainCamera")
		loading_screen = main_node.get_node("CanvasLayer/LoadingScreen")
		loading_screen.visible = true
		for node in main_node.get_children():
			on_node_added(node)
			
	tree.node_added.connect(on_node_added)
	
func on_finished_loading_scenes() -> void:
	##Make sure they are all loaded
	if scene_data_dict.keys().size() < loadable_scenes_size: return
	for scene_name : String in scene_data_dict:
		scene_data_dict[scene_name].set_teleport_points()
	load_player()
	direct_teleport_player(og_scene_name)
	finished_loading.emit()
	# GuiSystem.fade_loading_screen_out()
	# 	print("Faded screen out")
	
func get_scene(scene_name : String) -> LoadableScene:
	assert(scene_data_dict.has(scene_name), scene_name + " does not exist!")
	return scene_data_dict[scene_name]

func store_scene_info(node : Node3D) -> void:
	var node_name : String = node.name
	var node_instance : Node3D = node
	var cell_grid : Vector3
	if !cell_grids.has(node_name):
		cell_grids[node_name] = Vector3(1,1,1)
	cell_grid = cell_grids[node_name]
	var new_scene_data : LoadableScene = LoadableScene.new(
		node_instance,
		main_node_data,
		cell_grid,
		)
	scene_data_dict[node_name] = new_scene_data
	
	if og_scene_name == "" and new_scene_data.cell_manager.scene_aabb.intersects(player_aabb): #check intersection
		og_scene_name = node.name
	
	print("Stored scene info for ", node.name, " | ", Time.get_ticks_msec())
	added_scene.emit()

func load_player() -> void:
	loaded = true
	if !is_instance_valid(player):
		player = player_file.instantiate()
		player.global_position = player_spawn_pos
	player.ready.connect(func() -> void:
		Globals.player = player
		)
	main_node.add_child.call_deferred(player)
	main_camera.player = player
	
func on_node_added(node:Node) -> void:
	if loaded or !(node is Node3D): return
	if node.is_in_group("player"):
		GuiSystem.fade_loading_screen_in()
		player = node
		update_player_aabb()
		player_spawn_pos = player.global_position
		main_node.remove_child(node)
	elif node.is_in_group("loadable_scene"):
		node.ready.connect(store_scene_info.bind(node))

func update_player_aabb() -> void:
	if !player.is_inside_tree(): return
	player_aabb = Utils.calculate_node_aabb(player)

func reset() -> void:
	print("Reset player")
	if main_node == null: return
	direct_teleport_player(og_scene_name)

##LOADING/OFFLOADING
func load_scene(scene_name:String) -> Node3D:
	print("Attempting to load ", scene_name)
	if main_node == null: return
	if scene_name == "" or !scene_data_dict.has(scene_name): 
		assert(false, "Scene " + scene_name + " doesn't exist/isn't tagged with loadable_scene!")
		return
	#trying to load the currently loaded scene
	if active_scene_name == scene_name: 
		return loaded_scenes.front().instance
	active_scene_name = scene_name
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
##END LOADING/OFFLOADING

##TELEPORTING
func scene_loader_teleport(scene_name : String, new_position : TeleportPointData) -> void:
	var screen_tween : Tween = GuiSystem.fade_loading_screen_in()
	screen_tween.finished.connect(func() -> void:
		scene_teleport_pos = new_position.teleport_pos
		var scene : Node3D = load_scene(scene_name)
		scene.ready.connect(func() -> void:
			print("Teleporting player to ", scene_name)
			player.global_position = new_position.teleport_pos
			GlobalCameraScript.move_camera_jump.emit()
			
			offload_old_scenes()
			await tree.create_timer(1).timeout
			GuiSystem.fade_loading_screen_out()
			GlobalCameraScript.move_camera_smooth.emit()
		)
	)

func direct_teleport_player(scene_name : String) -> void:
	if scene_name == active_scene_name: return
	GuiSystem.set_gui_enabled(true)
	var target_pos : TeleportPointData = scene_data_dict[scene_name].main_teleport_point
	assert(target_pos != null, "" + scene_name + " doesn't have a teleport point assigned. Make sure all your scenes have at least one TeleportPoint.tscn'!")
	scene_loader_teleport(scene_name, target_pos)
##END TELEPORTING

##NPCs
func get_active_npc(npc_name : String) -> NPCData:
	return active_scene.get_npc(npc_name)
