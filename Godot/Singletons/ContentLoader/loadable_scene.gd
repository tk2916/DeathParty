class_name LoadableScene extends GameObject

#SceneLoaders
var scene_loader_dict : Dictionary[String, SceneLoaderData] = {} #node name, teleport position

#Main teleport (set by content_loader.gd)
var main_teleport_point : Vector3 = Vector3(-1,-1,-1)
var main_teleport_point_name : String

#Cells
var cell_manager : CellManager
var cell_debugger : ContentLoaderDebugMenu

#NPCs
var npc_dict : Dictionary[String, NPCData] = {}

##INITIAL LOAD --------------------------
func _init(
	_instance : Node3D, 
	_parent_obj : GameObject,
	_cell_grid : Vector3 = Vector3(1,1,1)
) -> void:
	super(_instance, _parent_obj)
	
	file = load(filepath)
	#print("Initializing Scene for ", name)
	
	var collision_shape : CollisionShape3D = instance.get_node("RoomArea")
	aabb = Utils.get_collision_shape_aabb(collision_shape)
	cell_manager = CellManager.new(self, _cell_grid)
	cell_debugger = ContentLoaderDebugMenu.new(self)
	# get children
	find_child_scenes(instance, self, self)
	offload()
##END INITIAL LOAD

##LOADING -------------------------------
func load_files(on : bool = true):
	for obj : SceneObject in child_objects:
		obj.load_async(on) #async load assets

func load_in() -> Node3D:
	##UI
	max_objects_per_frame = cell_manager.max_objects_per_frame
	#print("Max objects per frame: ", max_objects_per_frame)
	instance = file.instantiate()
	instance.ready.connect(func() -> void:
		print(name, " finished loading")
		)
	#print("Instance for ", name, " is ", instance)
	instance.transform = transform
	parent_node.add_child.call_deferred(instance)
	#instance.call_deferred("set_global_transform", transform)
	load_files()
	super() #loads children
	cell_debugger.load_in()
	cell_manager.load_in() #cell manager sends data to cell debugger
	return instance

func offload() -> void:
	#thread.wait_to_finish()
	super() #offloads children & self
	load_files(false)
	cell_debugger.offload()
	cell_manager.offload()
	
##END LOADING

##SCENE LOADERS ------------------------------------	
func get_scene_loader(loader_name:String) -> SceneLoaderData:
	return scene_loader_dict[loader_name]

func get_all_scene_loaders() -> Array[SceneLoaderData]:
	var arr : Array[SceneLoaderData] = []
	for key : String in scene_loader_dict:
		var value : SceneLoaderData = scene_loader_dict[key]
		arr.push_back(value)
	return arr

func set_main_teleport(point_name : String, point : Vector3) -> void:
	#print("Set main teleport for ", name, ": ", point_name)
	main_teleport_point_name = point_name
	main_teleport_point = point
##END SCENE LOADERS

##NPC
func get_npc(npc_name : String) -> NPCData:
	if npc_dict.has(npc_name):
		return npc_dict[npc_name]
	return null
