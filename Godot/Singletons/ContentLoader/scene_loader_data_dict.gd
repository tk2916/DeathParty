class_name SceneLoaderDataDictionary

var scene_Loader_array : Dictionary[String, SceneLoaderData] = {}

func add_entry(name:String, data:SceneLoaderData):
	scene_Loader_array[name] = data
	
func get_entry(name:String):
	return scene_Loader_array[name]
