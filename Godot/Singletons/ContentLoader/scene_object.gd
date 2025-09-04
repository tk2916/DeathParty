class_name SceneObject extends GameObject

var scene : LoadableScene
var owner_cells : Array[Cell]

signal file_loaded

func _init(
	_scene : LoadableScene, 
	_instance : Node3D,
	_parent_obj : GameObject = null
) -> void:
	super(_instance, _parent_obj)
	scene = _scene
	
	if instance is Interactable:
		var interactable : Interactable = instance as Interactable
		var collision_shape : CollisionShape3D = interactable.interaction_detector.collision_shape
		aabb =  Utils.get_collision_shape_aabb(collision_shape)
	elif instance is SceneLoader:
		var collision_shape : CollisionShape3D = instance.get_node("CollisionShape3D")
		aabb = Utils.get_collision_shape_aabb(collision_shape)
	elif instance is InteractionDetector:
		var collision_shape : CollisionShape3D = instance.collision_shape
		aabb = Utils.get_collision_shape_aabb(collision_shape)
	else:
		aabb = Utils.calculate_node_aabb(instance)
		
	scene.cell_manager.get_assigned_cells(self)
	# get children
	find_child_scenes(instance, self, scene)
	#print("Initiated object data for : ", name, " | file: ", file)

func load_in() -> Node3D:
	var start = Time.get_ticks_msec()
	max_objects_per_frame = scene.cell_manager.max_objects_per_frame
	if !is_instance_valid(parent_node):
		if not parent_obj.instance.is_node_ready():
			#sometimes call_deferred() means it's not added immediately
			await parent_obj.instance.ready
		#print("Parent instance: ", parent_obj.instance, " | active: ", active)
		#parent_node = parent_obj.instance.get_node(local_path)
	assign_existing_node()
	#print("Loading in node: ", name, " ", parent_obj.name, " ", instance)
	if !is_instance_valid(instance):
		if file == null:
			await file_loaded
		assert(file != null, "File for "+name+" is nil (are you loading the Resource?)")
		instance = file.instantiate()
		instance.name = name
		##add instance to tree (case where children are in different quadrants)
		active = true
		
		#await parent_node.get_tree().process_frame #lets other things happen
		assert(instance != null, name + " doesn't have the NPC/object script attached to it in its base scene!")
		instance.transform = transform
		parent_node.add_child.call_deferred(instance)
		#await parent_node.get_tree().process_frame #lets other things happen
		#instance.call_deferred("set_global_transform", transform)
	await super()
	var duration = (Time.get_ticks_msec() - start)
	#print("Duration loading in ", name, ": ", duration, " ms")
	return instance

func offload() -> void:
	#might not be offloaded bc another cell is still active
	if toggled:
		#if toggled, we check if it's active in another cell
		var deactivate : bool = true
		for cell : Cell in owner_cells:
			if cell.active == true:
				deactivate = false
				break
		if !deactivate: return
	super()

func load_async(loading_in : bool = true) -> void:
	if loading_in == false:
		file = null
		return
	if file != null:
		file_loaded.emit()
		return
	ResourceLoader.load_threaded_request(filepath)
	while true:
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(filepath, progress)
		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				file = ResourceLoader.load_threaded_get(filepath)
				file_loaded.emit()
				break
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				await scene.get_tree().process_frame
			ResourceLoader.THREAD_LOAD_FAILED:
				break

func info() -> String:
	var parent_info : String = super()
	var stats : Dictionary[String, Variant] = {
		scene = scene.name,
		owner_cells = owner_cells.size(),
	}
	return parent_info + Utils.dict_to_string(stats)

func add_cell(cell:Cell) -> void:
	owner_cells.push_back(cell)

func assign_existing_node() -> void:
	if !is_instance_valid(parent_node):
		parent_node = parent_obj.instance.get_node(local_path)
	if !is_instance_valid(instance):
		instance = parent_node.get_node_or_null(name)
