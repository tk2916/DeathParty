class_name SceneData

#Scene Info
var name : String
var position : Vector3
var file : PackedScene
var instance : Node3D = null
var active : bool = false

#SceneLoaders
var scene_loader_dict : Dictionary[String, SceneLoaderData] = {} #node name, teleport position
var scene_loader_arr : Array[SceneLoaderData] = []

#Main teleport
var main_teleport_point : Vector3 = Vector3(-1,-1,-1)
var main_teleport_point_name : String

#Quadrants
#each QuadrantRow will hold 3 Quadrants, and there are 3 QuadrantRows
var scene_quadrants : Array[QuadrantRow] = []
var active_quadrants : Array[Quadrant] = []
var scene_aabb : AABB
const WIDTH_DIVIDE = 4
const HEIGHT_DIVIDE = 4
const DEPTH_DIVIDE = 1

func load_in(parent_scene : Node3D) -> Node3D:
	instance = file.instantiate()
	instance.ready.connect(func() -> void:
		print(name, " finished loading")
		)
	instance.position = position
	for child : Node in instance.get_children():
		if child is SceneLoader: #re-set teleport positions
			var scene_loader_data : SceneLoaderData = get_scene_loader(child.name)
			child.teleport_pos = scene_loader_data.teleport_pos
	parent_scene.add_child.call_deferred(instance)
	return instance

func offload(parent_scene : Node3D) -> void:
	parent_scene.remove_child.call_deferred(
		instance)
	instance.queue_free()

func player_collide(player_aabb:AABB) -> void:
	var quad_row_i = -1
	var quad_i = -1
	var player_found : bool = false
	for quad_row : QuadrantRow in scene_quadrants:
		if player_found: break
		quad_row_i += 1
		quad_i = -1
		for quad : Quadrant in quad_row.row:
			quad_i += 1
			if quad.intersects(player_aabb):
				player_found = true
				break
	
	var adjacent_quadrants = find_adjacent_quadrants(quad_row_i, quad_i)
	for quad : Quadrant in active_quadrants:
		if !(quad in adjacent_quadrants):
			quad.set_active(instance, false) #offload
	for quad: Quadrant in adjacent_quadrants:
		quad.set_active(instance, true)
		
	active_quadrants = adjacent_quadrants
	
func find_adjacent_quadrants(quad_row_i : int, quad_i : int) -> Array[Quadrant]:
	var adjacent : Array[Quadrant]
	get_quads_from_row(adjacent, quad_row_i, quad_i-1, quad_i+1)
	if quad_row_i > 0:
		get_quads_from_row(adjacent, quad_row_i-1, quad_i-1, quad_i+1)
	if quad_row_i < scene_quadrants.size()-1:
		get_quads_from_row(adjacent, quad_row_i-1, quad_i-1, quad_i+1)
	return adjacent

func get_quads_from_row(arr : Array[Quadrant], row_i:int, start:int, end:int) -> void:
	var row : Array[Quadrant] = scene_quadrants[row_i].row
	for i in range(row.size()):
		if i < start or (i > end or end == -1): continue
		var quadrant : Quadrant = row[i]
		arr.push_back(quadrant)

func add_scene_loader(loader:SceneLoader) -> void:
	var loader_data : SceneLoaderData = SceneLoaderData.new(loader.teleport_pos, loader.name)
	scene_loader_dict[loader.name] = loader_data
	scene_loader_arr.push_back(loader_data)
	
func get_scene_loader(loader_name:String) -> SceneLoaderData:
	return scene_loader_dict[loader_name]

func get_all_scene_loaders() -> Array[SceneLoaderData]:
	return scene_loader_arr

func set_main_teleport(point_name : String, point : Vector3) -> void:
	print("Set main teleport for ", name, ": ", point_name)
	main_teleport_point_name = point_name
	main_teleport_point = point
	
func create_quadrants():
	var scene_width : float = scene_aabb.size.x
	var scene_height : float = scene_aabb.size.y
	var scene_depth : float = scene_aabb.size.z
	
	var quad_width : float = scene_width / WIDTH_DIVIDE
	var quad_height : float = scene_height / HEIGHT_DIVIDE
	var quad_depth : float = scene_depth / DEPTH_DIVIDE
	
	var quad_size = Vector3(quad_width, quad_height, quad_depth)
	
	#CREATE QUADRANTS
	for row in range(WIDTH_DIVIDE):
		scene_quadrants.push_back(QuadrantRow.new())
		for col in range(HEIGHT_DIVIDE):
			var quad_origin = Vector3(
				scene_aabb.position.x + (col * quad_width),
				scene_aabb.position.y + (row * quad_height),
				scene_aabb.position.z
			)
			var quad_aabb = Quadrant.new(quad_origin, quad_size)
			scene_quadrants.back().row.push_back(quad_aabb)
			
func assign_interactables(interactables : Array[InteractableData]):
	for quad_row : QuadrantRow in scene_quadrants:
		for quad : Quadrant in quad_row.row:
			for data : InteractableData in interactables:
				quad.add_interactable(data) #adds it if it intersects
