class_name GameObject extends RefCounted

var name : String
var filepath : String
var file : PackedScene
var transform : Transform3D
var g_pos : Vector3
var aabb : AABB
var instance : Node3D = null
var parent_node : Node3D = null
var parent_obj : GameObject
var local_path : NodePath

var active : bool = false
var child_objects : Array[GameObject]
var max_objects_per_frame : int = 10000

func _init(_instance : Node3D, _parent_obj : GameObject = null) -> void:
	instance = _instance
	name = instance.name
	filepath = instance.scene_file_path
	parent_obj = _parent_obj
	if parent_obj:
		parent_node = instance.get_parent()
		local_path = parent_obj.instance.get_path_to(parent_node)
		
	transform = instance.transform
	#print("Initiated object data for : ", name, " | file: ", file)

func load_in() -> Node3D:
	'''
	IMPLEMENT YOUR OWN LOGIC FOR LOADING IN YOUR GameObject
	THEN, CALL super() TO LOAD IN CHILDREN (below)
	'''
	
	#If any nodes are already toggled, load em in
	#ONLY LOAD/OFFLOAD MAX # OF THINGS AT A TIME
	active = true
	var objCounter : int = 0
	for obj : GameObject in child_objects:
		objCounter += 1
		if obj.active == true:
			obj.load_in()
		else:
			obj.offload()
		if objCounter > max_objects_per_frame:
			await parent_obj.instance.get_tree().process_frame
			objCounter = 0
			
	return instance

func offload() -> void:
	active = false
	if not is_instance_valid(instance) or not is_instance_valid(parent_node):
		return
	if instance.get_parent() != parent_node:
		return
		
	#parent_node.remove_child.call_deferred(instance)
	instance.queue_free()
	#instance = null
	for obj : GameObject in child_objects:
		obj.offload()
			
## END LOADING

func info() -> String:
	var stats : Dictionary[String, Variant] = {
		name = name,
		filepath  = filepath,
		local_path = local_path,
		file = file,
		instance = instance,
		parent_node = parent_node,
		parent_obj = parent_obj.name,
		parent_obj_instance = parent_obj.instance,

		active = active,
		child_objects = child_objects.size()
	}
	return Utils.dict_to_string(stats)
	
func find_child_scenes(
	parent_instance : Node3D, 
	parent_obj : GameObject, 
	scene : LoadableScene
) -> void:
	#print("Getting children for obj ", parent_obj.name)
	var children : Array[Node] = Utils.get_children_exclusive(
		parent_instance,
		[Node3D],
		Utils.LIST_TYPE.WHITELIST
	)
	for obj : Node3D in children:
		if obj is Player: continue
		if obj.scene_file_path == "":
			find_child_scenes(obj, parent_obj, scene)
		else:
			var new_obj : SceneObject
			if obj is SceneLoader:
				new_obj = SceneLoaderData.new(
					scene,
					obj,
					parent_obj,
				)
				scene.scene_loader_dict[obj.name] = new_obj
			else:
				var visual_node : VisualInstance3D = Utils.find_first_child_of_class(obj, VisualInstance3D)
				if visual_node == null: continue
				new_obj = SceneObject.new(
					scene,
					obj,
					parent_obj
				)
			child_objects.push_back(new_obj)

func get_surface_materials(mesh : MeshInstance3D) -> Array[Material]:
	var arr : Array[Material] = []
	for i in range(0,2):
		var material : Material = mesh.get_active_material(i)
		if material:
			arr.push_back(material)
	return arr
		
