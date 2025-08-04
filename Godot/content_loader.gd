extends Node

var player_aabb : AABB

var scene_name_to_scene : Dictionary[String, PackedScene] = {}
var scene_to_position : Dictionary[String, Vector3] = {}

@onready var main_node : Node3D = get_tree().root.get_node_or_null("Main")

var loaded_scenes : Array[Node3D]

var og_scene : String = ""

func _ready() -> void:
	if main_node:
		for node in main_node.get_children():
			on_node_added(node)
	get_tree().node_added.connect(on_node_added)

func find_room_containing_player():
	var loadable_scenes = get_tree().get_nodes_in_group("loadable_scene")
	for node : Node3D in loadable_scenes:
		# find the room the player spawned in
		# save the positions of each scene and delete them
		scene_to_position[node.name] = node.position
		scene_name_to_scene[node.name] = load(node.scene_file_path)
		var scene_aabb : AABB = calculate_node_aabb(node)
		if scene_aabb.intersects(player_aabb): #check intersection
			og_scene = node.name
			print("New og scene: ", og_scene)
			
		main_node.remove_child(node)
		node.queue_free()
		
	print("Found OG scene: ", og_scene)

func on_node_added(node:Node):
	if node.is_in_group("player"):
		player_aabb = calculate_node_aabb(node)
		find_room_containing_player()
		load_scene(og_scene)

func calculate_node_aabb(node3d : Node3D) -> AABB:
	var visual_nodes : Array[Node] = node3d.find_children("*", "VisualInstance3D", true, false)
	assert(!visual_nodes.is_empty(), "There are no visual nodes in this scene!")
	var aabb : AABB = visual_nodes[0].global_transform * visual_nodes[0].get_aabb()
	for node : Node in visual_nodes:
		if (node == visual_nodes[0] or 
		!(node is VisualInstance3D) or 
		(node is Light3D) or
		node3d.name == "PlayerCameraLocation"
		): continue
		var node_aabb : AABB = node.get_aabb()
		var global_aabb : AABB = node.global_transform * node_aabb
		aabb = aabb.merge(global_aabb)
		
	return aabb

func reset() -> void:
	if main_node == null: return
	offload_old_scenes()
	offload_old_scene() #get the final one (the current scene)
	load_scene(og_scene)

func load_scene(scene_name:String):
	if main_node == null or scene_name == "": return
	if !scene_name_to_scene.has(scene_name): 
		assert(false, "Scene " + scene_name + " doesn't exist/isn't tagged with loadable_scene!")
		return
	#trying to load the currently loaded scene
	if loaded_scenes.size() > 0 && loaded_scenes.front().name == scene_name: return
	
	var scene : PackedScene = scene_name_to_scene[scene_name]
		
	var scene_instance = scene.instantiate()
	main_node.add_child(scene_instance)
	scene_instance.position = scene_to_position[scene_name]
	loaded_scenes.push_front(scene_instance)


func offload_old_scenes():
	for n in range(1, loaded_scenes.size()): #skip first one (current scene)
		offload_old_scene()


func offload_old_scene():
	if main_node == null: return
	var old_loaded_scene = loaded_scenes.pop_back()
	#if old_loaded_scene == null: return
	main_node.remove_child(old_loaded_scene)
	old_loaded_scene.queue_free()
