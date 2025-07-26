extends Node

const scene_name_to_scene : Dictionary[String, PackedScene] = {
	"Room":preload("res://World/room2.tscn"),
	"Entrance":preload("res://rooms/entrance.tscn"),
	"PartyRoom":preload("res://rooms/party_room/party_room.tscn"),
}

const scene_to_position : Dictionary[String, Vector3] = {
	"Room":Vector3(2.5,0,0),
	"Entrance":Vector3(-27.512,0,0),
	"PartyRoom":Vector3(-24.161,0,-17.392),
}

@onready var main_node : Node3D = get_tree().root.get_node_or_null("Main")
#var currently_loaded_scene : Node3D
#var old_loaded_scene : Node3D

var loaded_scenes : Array[Node3D]

var og_scene : String = "Room"

func _ready() -> void:
	if main_node == null: return
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
var fps_timer: float = 0.0
var fps_update_interval: float = 1.0  # Print every second

func _process(delta: float) -> void:
	fps_timer += delta
	
	if fps_timer >= fps_update_interval:
		var current_fps = Engine.get_frames_per_second()
		#print("FPS: ", current_fps)
		fps_timer = 0.0  # Reset timer
