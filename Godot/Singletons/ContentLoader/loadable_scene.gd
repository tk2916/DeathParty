class_name LoadableScene extends GameObject

#SceneLoaders
var scene_loader_dict : Dictionary[String, SceneLoaderData] = {} #node name, teleport position
var teleport_points : Array[TeleportPointData]
var main_teleport_point : TeleportPointData

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
	instance = file.instantiate()
	instance.ready.connect(func() -> void:
		print(name, " finished loading")
		)
	instance.transform = transform
	parent_node.add_child.call_deferred(instance)
	load_files()
	super() #loads children
	cell_debugger.load_in()
	cell_manager.load_in() #cell manager sends data to cell debugger
	return instance

func offload() -> void:
	super() #offloads children & self
	load_files(false)
	cell_debugger.offload()
	cell_manager.offload()
##END LOADING

##SCENE LOADERS
func set_teleport_points() -> void:
	for loader_name : String in scene_loader_dict:
		scene_loader_dict[loader_name].set_teleport_point()
	if teleport_points.size() > 0:
		main_teleport_point = teleport_points[0]
		
##END SCENE LOADERS

##NPC
func get_npc(npc_name : String) -> NPCData:
	if npc_dict.has(npc_name):
		return npc_dict[npc_name]
	return null
