class_name SceneLoaderData

var name : String
var teleport_pos : Vector3
var target_scene_name : String

func _init(_teleport_pos : Vector3, _scene_loader_name : String) -> void:
	name = _scene_loader_name
	teleport_pos = _teleport_pos
	target_scene_name = _scene_loader_name.substr(12)
	
