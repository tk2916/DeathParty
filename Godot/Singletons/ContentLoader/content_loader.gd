extends Node

var player : Player
var player_file : PackedScene = preload("res://Entities/player.tscn")
var player_aabb : AABB
var player_spawn_pos : Vector3

var scene_to_file : Dictionary[String, PackedScene] = {}
var scene_to_position : Dictionary[String, Vector3] = {}
var scene_loader_teleport_positions : Dictionary[String, SceneLoaderDataDictionary] = {}

@onready var main_node : Node3D = get_tree().root.get_node_or_null("Main")

var loaded_scenes : Array[Node3D]

var og_scene : String

var loading_screen : ColorRect

func _ready() -> void:
	if main_node:
		loading_screen = main_node.get_node("CanvasLayer/LoadingScreen")
		for node in main_node.get_children():
			on_node_added(node)
			
	get_tree().node_added.connect(on_node_added)
	
func fade_loading_screen_in(fadeout_delay : float = 0) -> Tween:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(loading_screen, "modulate:a", 1, .2)
	if fadeout_delay > 0:
		tween.tween_callback(fade_loading_screen_out.bind(fadeout_delay))
	return tween
	
func fade_loading_screen_out(fadeout_delay : float = 0) -> Tween:
	player.movement_disabled = true
	await get_tree().create_timer(fadeout_delay).timeout
	player.movement_disabled = false
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(loading_screen, "modulate:a", 0, 1)
	return tween

func find_room_containing_player() -> void:
	var loadable_scenes = get_tree().get_nodes_in_group("loadable_scene")
	for node : Node3D in loadable_scenes:
		# find the room the player spawned in
		# save the positions of each scene and delete them
		node.ready.connect(store_scene_info.bind(node))

func store_scene_info(node : Node3D) -> void:
	var filepath : String = node.scene_file_path
	var filename : String = node.name#filepath.get_file()
	
	scene_to_file[filename] = load(filepath)
	scene_to_position[filename] = node.position
	scene_loader_teleport_positions[filename] = SceneLoaderDataDictionary.new()
	for child in node.get_children():
		if child is SceneLoader:
			##Save SceneLoader data to reapply on load in (it keeps getting lost)
			var teleport_data : SceneLoaderData = SceneLoaderData.new()
			teleport_data.teleport_pos = child.teleport_pos
			print("Contentloader teleport point: ", child.name, " | ", child.teleport_pos)
			scene_loader_teleport_positions[filename].add_entry(child.name, teleport_data)
	
	var collision_shape : CollisionShape3D = node.get_node("RoomArea")
	var room_area : BoxShape3D = collision_shape.shape
	var scene_aabb : AABB = AABB(-room_area.size / 2.0, room_area.size)#calculate_node_aabb(node.get_node("RoomArea"))
	scene_aabb = collision_shape.global_transform * scene_aabb
	main_node.remove_child(node)
	node.queue_free()
	if scene_aabb.intersects(player_aabb): #check intersection
		og_scene = node.name
		print("New og scene: ", og_scene)
		load_scene(og_scene)
		await get_tree().create_timer(2.5).timeout
		on_og_scene_loaded()

func on_og_scene_loaded() -> void:
	print("Fading screen out")
	player.set_physics_process(true)
	player.visible = true
	fade_loading_screen_out()
	print("Finished fading screen")

func on_node_added(node:Node) -> void:
	#if player != null: return
	if node.is_in_group("player"):
		fade_loading_screen_in()
		player = node
		player.visible = false
		player.set_physics_process(false)
		player_aabb = calculate_node_aabb(node)
		find_room_containing_player()

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
	if main_node == null: return
	fade_loading_screen_in()
	offload_old_scenes()
	offload_old_scene() #get the final one (the current scene)
	load_scene(og_scene)
	on_og_scene_loaded()

func load_scene(scene_name:String) -> void:
	print("Attempting to load ", scene_name)
	if main_node == null: return
	if scene_name == "" or !scene_to_file.has(scene_name): 
a		assert(false, "Scene " + scene_name + " doesn't exist/isn't tagged with loadable_scene!")
		return
	var scene : PackedScene = scene_to_file[scene_name]
	#trying to load the currently loaded scene
	if loaded_scenes.size() > 0 && loaded_scenes.front().name == scene_name: return
	
	var scene_instance : Node3D = scene.instantiate()
	scene_instance.position = scene_to_position[scene_name]
	for child : Node in scene_instance.get_children():
		if child is SceneLoader: #re-set teleport positionss
			var scene_loader_data : SceneLoaderData = scene_loader_teleport_positions[scene_name].get_entry(child.name)
			#print("Setting scene loader positions: ", scene_loader_data.teleport_pos)
			child.teleport_pos = scene_loader_data.teleport_pos
			print("Loaded sceneLoader ", child.name, " | Scenegoingright: ", child.scene_going_right)
	scene_instance.ready.connect(callbck.bind(scene_name))
	main_node.add_child(scene_instance)
	loaded_scenes.push_front(scene_instance)

func callbck(scene_name :String):
	print(scene_name, " finished loading")

func offload_old_scenes() -> void:
	for n in range(1, loaded_scenes.size()): #skip first one (current scene)
		offload_old_scene()

func offload_old_scene() -> void:
	if main_node == null: return
	var old_loaded_scene = loaded_scenes.pop_back()
	if old_loaded_scene == null: return
	main_node.remove_child(old_loaded_scene)
	old_loaded_scene.queue_free()
