class_name SceneData

#Scene Info
var name : String
var transform : Transform3D
var file : PackedScene
var instance : Node3D = null
var parent_scene : Node3D = null
var active : bool = false

#SceneLoaders
var scene_loader_dict : Dictionary[String, SceneLoaderData] = {} #node name, teleport position
#var scene_loader_arr : Array[SceneLoaderData] = []

#Main teleport (set by content_loader.gd)
var main_teleport_point : Vector3 = Vector3(-1,-1,-1)
var main_teleport_point_name : String

#Quadrants
#each QuadrantRow will hold 3 Quadrants, and there are 3 QuadrantRows
var scene_quadrants : Array[QuadrantPlane] = []
var active_quadrants : Array[Quadrant] = []
var scene_aabb : AABB
var WIDTH_DIVIDE = 4
var HEIGHT_DIVIDE = 4
var DEPTH_DIVIDE = 4
var scene_interactables : Array[InteractableData] = []

##INITIAL LOAD --------------------------
func _init(
	_name : String, 
	_file : PackedScene,
	_instance : Node3D, 
	_parent_scene : Node3D,
	_quadrant_grid : Vector3 = Vector3(1,1,1)
) -> void:
	print("Initializing SceneData for ", _name)
	name = _name
	file = _file
	transform = _instance.transform
	instance = _instance
	parent_scene = _parent_scene
	WIDTH_DIVIDE = _quadrant_grid.x
	HEIGHT_DIVIDE = _quadrant_grid.y
	DEPTH_DIVIDE = _quadrant_grid.z
	var collision_shape : CollisionShape3D = instance.get_node("RoomArea")
	scene_aabb = Utils.get_collision_shape_aabb(collision_shape)
	create_quadrants()
	classify_children()
	assign_interactables(scene_interactables)
	offload()
	
func classify_children():
	loop_through_descendants(store_scene_loader, store_interactable)
	print("Scene interactables for ", name, ": ", scene_interactables)

func loop_through_descendants(
	scene_loader_func : Callable, 
	interactable_func : Callable
	):
	var descendants : Array[Node] = Utils.get_descendants(instance, [Light3D], true)
	for child in descendants:
		if child is SceneLoader:
			##Save SceneLoader data to reapply on load in (it keeps getting lost)
			scene_loader_func.call(child)
		elif child is Interactable:
			interactable_func.call(child)

##END INITIAL LOAD

##COMPONENT ON STORE/ON LOAD FUNCTIONS
func store_scene_loader(loader:SceneLoader) -> void:
	var loader_data : SceneLoaderData = SceneLoaderData.new(loader.teleport_pos, loader.name)
	scene_loader_dict[loader.name] = loader_data
	
func scene_loader_on_load(loader : SceneLoader) -> void:
	var scene_loader_data : SceneLoaderData = get_scene_loader(loader.name)
	loader.teleport_pos = scene_loader_data.teleport_pos

func store_interactable(interactable : Interactable) -> void:
	var name = interactable.name
	var packed_scene : PackedScene = load(interactable.scene_file_path)
	var transform : Transform3D = interactable.transform
	var global_position : Vector3 = interactable.global_position
	var collision_shape : CollisionShape3D = interactable.interaction_detector.collision_shape
	var child_aabb = Utils.get_collision_shape_aabb(collision_shape)
	var data : InteractableData = InteractableData.new(
		name,
		packed_scene, 
		interactable
		)
	scene_interactables.push_back(data)
	
func interactable_on_load(interactable : Interactable) -> void:
	print("Found interactable ", interactable.name)
	parent_scene.remove_child(interactable)
	interactable.queue_free()
	
##END COMPONENT FUNCS

##LOADING -------------------------------

func load_in() -> Node3D:
	print("Loading in ", name)
	active = true
	instance = file.instantiate()
	instance.ready.connect(func() -> void:
		loop_through_descendants(scene_loader_on_load, interactable_on_load)
		print(name, " finished loading")
		)
	instance.transform = transform
	
	parent_scene.add_child.call_deferred(instance)
	update_active_quadrants()
	GlobalPlayerScript.update_quadrants.connect(update_active_quadrants)
	return instance

func offload() -> void:
	active = false
	GlobalPlayerScript.update_quadrants.disconnect(update_active_quadrants)
	for quad_plane : QuadrantPlane in scene_quadrants:
		for quad_row : QuadrantRow in quad_plane.plane:
			for quad : Quadrant in quad_row.row:
				quad.set_active(instance, false)
	parent_scene.remove_child.call_deferred(
		instance)
	instance.queue_free()
	
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

##QUADRANTS -------------------------------------
func create_quadrants():
	#print("Creating quadrants for ", name)
	var scene_width : float = scene_aabb.size.x
	var scene_height : float = scene_aabb.size.y
	var scene_depth : float = scene_aabb.size.z
	
	var quad_width : float = scene_width / WIDTH_DIVIDE
	var quad_height : float = scene_height / HEIGHT_DIVIDE
	var quad_depth : float = scene_depth / DEPTH_DIVIDE
	
	var quad_size = Vector3(quad_width, quad_height, quad_depth)
	
	var parent_transform : Transform3D = parent_scene.global_transform
	
	#CREATE QUADRANTS
	var quadrant_id : int = 0
	for row in range(WIDTH_DIVIDE):
		scene_quadrants.push_back(QuadrantPlane.new())
		var pos_x : float = scene_aabb.position.x + (row * quad_width)
		
		for col in range(HEIGHT_DIVIDE):
			var current_plane : QuadrantPlane = scene_quadrants.back()
			current_plane.push_back(QuadrantRow.new())
			var pos_y : float = scene_aabb.position.y + (col * quad_height)
			
			for depth in range(DEPTH_DIVIDE):
				var current_row : QuadrantRow = current_plane.back()
				var pos_z : float = scene_aabb.position.z + (depth * quad_depth)
				var quad_origin = Vector3(
					pos_x,
					pos_y,
					pos_z
				)
				#print("Quadrant ", quadrant_id, " [", row, ",", col, ",", depth, "]:")
				#print("  Origin: ", quad_origin)
				#print("  End: ", quad_origin + quad_size)
				
				#print("Quad origin ", quadrant_id, ": ", quad_origin)
				var quad_aabb = Quadrant.new(quadrant_id, quad_origin, quad_size)
				quadrant_id += 1
				current_row.push_back(quad_aabb)
			
func assign_interactables(interactables : Array[InteractableData]):
	#print("Assigning interactables: ", name, " | ", interactables.size())
	for data : InteractableData in interactables:
		for quad_plane : QuadrantPlane in scene_quadrants:
			#if data.quadrant_id != -1: break
			for quad_row : QuadrantRow in quad_plane.plane:
				#if data.quadrant_id != -1: break
				for quad : Quadrant in quad_row.row:
					quad.add_interactable(data) #adds it if it intersects
					#if data.quadrant_id != -1: break
					
func show_quadrants():
	#for quad_plane : QuadrantPlane in scene_quadrants:
		#for quad_row : QuadrantRow in quad_plane.plane:
	for i in range(active_quadrants.size()):#quad_row.size()):
		var quadrant = active_quadrants[i]
		
		# Create a mesh for each quadrant
		var mesh_instance = MeshInstance3D.new()
		var box_mesh = BoxMesh.new()
		box_mesh.size = quadrant.aabb.size
		mesh_instance.mesh = box_mesh
		
		# Position at the center of the AABB
		mesh_instance.position = quadrant.aabb.get_center()
		
		# Create transparent colored material
		var material = StandardMaterial3D.new()
		material.albedo_color = Color.GREEN#Color(randf(), randf(), randf(), 1.0)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color.a = 0.5  # Make it transparent
		mesh_instance.material_override = material
		
		mesh_instance.name = "QuadrantMesh"
		
		mesh_instance.add_to_group("quad_box")
		
		parent_scene.add_child(mesh_instance)

func update_active_quadrants() -> void:
	if not active: return
	ContentLoader.update_player_aabb()
	var player_aabb : AABB = ContentLoader.player_aabb
	#print("Player AABB: ", player_aabb.position, " size: ", player_aabb.size)
	#print("Player center: ", player_aabb.get_center())
	print("UPDATING QUADRANTS")
	var quad_plane_i = -1
	var quad_row_i = -1
	var quad_i = -1
	var player_found : bool = false
	for quad_plane : QuadrantPlane in scene_quadrants:
		quad_plane_i+=1
		quad_row_i = -1
		if player_found: break
		for quad_row : QuadrantRow in quad_plane.plane:
			if player_found: break
			quad_row_i += 1
			quad_i = -1
			for quad : Quadrant in quad_row.row:
				quad_i += 1
				if quad.intersects(player_aabb):
					print("Active quadrant: ", quad.id)
					player_found = true
					break
					
	#for mesh : Node in parent_scene.get_tree().get_nodes_in_group("quad_box"):
		#parent_scene.remove_child(mesh)
		#mesh.queue_free()
	var adjacent_quadrants = find_adjacent_quadrants(quad_plane_i, quad_row_i, quad_i)
	#print("Size of adjacent quadrants: ", adjacent_quadrants.size())
	for quad : Quadrant in active_quadrants:
		if !(quad in adjacent_quadrants):
			print("Un-activating quadrant ", quad.id)
			quad.set_active(instance, false) #offload
	for quad: Quadrant in adjacent_quadrants:
		quad.set_active(instance, true)
		
	active_quadrants = adjacent_quadrants
	#show_quadrants()
	
func find_adjacent_quadrants(quad_plane_i : int, quad_row_i : int, quad_i : int) -> Array[Quadrant]:
	var adjacent : Array[Quadrant] = []
	#check 3x3 cube
	var range_min : int = -2
	var range_max : int = 2
	for x in range(range_min, range_max):
		var new_plane_i = quad_plane_i + x
		if new_plane_i < 0 or new_plane_i >= WIDTH_DIVIDE:
			continue
		for y in range(range_min, range_max):
			var new_row_i = quad_row_i + y
			if new_row_i < 0 or new_row_i >= HEIGHT_DIVIDE:
				continue
			for z in range(range_min, range_max):
				var new_quad_i = quad_i + z
				if new_quad_i < 0 or new_quad_i >= DEPTH_DIVIDE:
					continue
				var quadrant : Quadrant = scene_quadrants[new_plane_i].plane[new_row_i].row[new_quad_i]
				adjacent.append(quadrant)
	return adjacent
