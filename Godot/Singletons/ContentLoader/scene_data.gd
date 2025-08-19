class_name SceneData

var scene_name : String

var scene_loader_dict : Dictionary[String, SceneLoaderData] = {} #node name, teleport position
var scene_loader_arr : Array[SceneLoaderData] = []

var main_teleport_point : Vector3 = Vector3(-1,-1,-1)
var main_teleport_point_name : String

func add_scene_loader(loader:SceneLoader) -> void:
	var loader_data : SceneLoaderData = SceneLoaderData.new(loader.teleport_pos, loader.name)
	scene_loader_dict[loader.name] = loader_data
	scene_loader_arr.push_back(loader_data)
	
func get_scene_loader(loader_name:String) -> SceneLoaderData:
	return scene_loader_dict[loader_name]

func get_all_scene_loaders() -> Array[SceneLoaderData]:
	return scene_loader_arr

func set_main_teleport(point_name : String, point : Vector3) -> void:
	print("Set main teleport for ", scene_name, ": ", point_name)
	main_teleport_point_name = point_name
	main_teleport_point = point
