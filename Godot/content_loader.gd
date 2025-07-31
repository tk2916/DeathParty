extends Node

var scene_name_to_scene : Dictionary[String, PackedScene] = {}
var scene_to_position : Dictionary[String, Vector3] = {}

@onready var main_node : Node3D = get_tree().root.get_node_or_null("Main")

var loaded_scenes : Array[Node3D]

var og_scene : String


func _ready() -> void:
	if main_node == null: return

	# get all loadable scenes in main
	var loadable_scenes = get_tree().get_nodes_in_group("loadable_scene")
	for node : Node3D in loadable_scenes:
		# find the room the player spawned in
		var bodies_in_room = node.get_overlapping_bodies()
		for body: Node3D in bodies_in_room:
			if body.is_in_group("player"):
				# set the og scene to the player's spawn room
				og_scene = str(node.name)
				break

		# save the positions of each scene and delete them
		scene_to_position[node.name] = node.position
		scene_name_to_scene[node.name] = load(node.scene_file_path)
		main_node.remove_child(node)
		node.queue_free()

	# reload the scene the player is spawning in
	load_scene(og_scene)


func reset() -> void:
	if main_node == null: return
	offload_old_scenes()
	offload_old_scene() #get the final one (the current scene)
	load_scene(og_scene)


func load_scene(scene_name:String):
	if main_node == null: return
	if !scene_name_to_scene.has(scene_name): return
	if loaded_scenes.size() > 0 && loaded_scenes.front().name == scene_name: return
	
	var scene : PackedScene = scene_name_to_scene[scene_name]
		
	var scene_instance = scene.instantiate()
	print("Loaded scene ", scene_name)
	main_node.add_child(scene_instance)
	scene_instance.position = scene_to_position[scene_name]
	loaded_scenes.push_front(scene_instance)


func offload_old_scenes():
	for n in range(1, loaded_scenes.size()): #skip first one (current scene)
		offload_old_scene()


func offload_old_scene():
	if main_node == null: return
	var old_loaded_scene = loaded_scenes.pop_back()
	main_node.remove_child(old_loaded_scene)
	old_loaded_scene.queue_free()


##FRAMERATE PRINTER
#var fps_timer: float = 0.0
#var fps_update_interval: float = 1.0  # Print every second


#func _process(delta: float) -> void:
	#fps_timer += delta
	#
	#if fps_timer >= fps_update_interval:
		#var current_fps = Engine.get_frames_per_second()
		#print("FPS: ", current_fps)
		#fps_timer = 0.0  # Reset timer
