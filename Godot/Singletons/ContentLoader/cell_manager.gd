class_name CellManager

var scene : LoadableScene

#each CellRow will hold X Cells, and there are X CellRows
var scene_cells : Array[CellPlane] = []
var number_of_cells : int = 0
var active_cells : Array[Cell] = []
var player_cell : Cell

var scene_aabb : AABB
var WIDTH_DIVIDE : int = 4
var HEIGHT_DIVIDE : int = 4
var DEPTH_DIVIDE : int = 4
var adjacent_range_min : int = -1
var adjacent_range_max : int = 2
#all SceneObjects in scene
var scene_objects : Array[SceneObject] = []

const OBJS_PER_FRAME = 1000
var max_objects_per_frame : int = OBJS_PER_FRAME

func _init(_scene : LoadableScene, _cell_grid : Vector3) -> void:
	scene = _scene
	WIDTH_DIVIDE = _cell_grid.x as int
	HEIGHT_DIVIDE = _cell_grid.y as int
	DEPTH_DIVIDE = _cell_grid.z as int
	
	scene_aabb = scene.aabb
	create_cells()

func load_in() -> void:
	## all cells are initially loaded, so put it in active_cells
	active_cells = []
	for cell_plane : CellPlane in scene_cells:
		for cell_row : CellRow in cell_plane.plane:
			for cell : Cell in cell_row.row:
				cell.load_in()
				active_cells.push_back(cell)
	print("CellManager for ", scene.name, " loading in.")
	if ContentLoader.loaded:
		update_active_cells(true)
	else:
		ContentLoader.finished_loading.connect(update_active_cells.bind(true))
	max_objects_per_frame = 10
	GlobalPlayerScript.update_cells.connect(update_active_cells)

func offload() -> void:
	max_objects_per_frame = OBJS_PER_FRAME
	if GlobalPlayerScript.update_cells.is_connected(update_active_cells):
		GlobalPlayerScript.update_cells.disconnect(update_active_cells)
	for cell_plane : CellPlane in scene_cells:
		for cell_row : CellRow in cell_plane.plane:
			for cell : Cell in cell_row.row:
				cell.set_active(false, false)
	
func create_cells() -> void:
	#print("Creating cells for ", name)
	number_of_cells = 0
	var scene_width : float = scene_aabb.size.x
	var scene_height : float = scene_aabb.size.y
	var scene_depth : float = scene_aabb.size.z
	
	var cell_width : float = scene_width / WIDTH_DIVIDE
	var cell_height : float = scene_height / HEIGHT_DIVIDE
	var cell_depth : float = scene_depth / DEPTH_DIVIDE
	
	var cell_size := Vector3(cell_width, cell_height, cell_depth)
	
	#CREATE QUADRANTS
	var cell_id : int = 0
	for row in range(WIDTH_DIVIDE):
		scene_cells.push_back(CellPlane.new())
		var pos_x : float = scene_aabb.position.x + (row * cell_width)
		
		for col in range(HEIGHT_DIVIDE):
			var current_plane : CellPlane = scene_cells.back()
			current_plane.push_back(CellRow.new())
			var pos_y : float = scene_aabb.position.y + (col * cell_height)
			
			for depth in range(DEPTH_DIVIDE):
				var current_row : CellRow = current_plane.back()
				var pos_z : float = scene_aabb.position.z + (depth * cell_depth)
				var cell_origin := Vector3(
					pos_x,
					pos_y,
					pos_z
				)
				#print("Cell ", cell_id, " [", row, ",", col, ",", depth, "]:")
				#print("  Origin: ", cell_origin)
				#print("  End: ", cell_origin + cell_size)
				
				#print("Quad origin ", cell_id, ": ", cell_origin)
				var cell_coords : Vector3 = Vector3(row, col, depth)
				var cell_aabb := Cell.new(self.scene, cell_id, cell_coords, cell_origin, cell_size)
				cell_id += 1
				current_row.push_back(cell_aabb)
				number_of_cells += 1

func get_assigned_cells(obj : SceneObject) -> void:
	for cell_plane : CellPlane in scene_cells:
		for cell_row : CellRow in cell_plane.plane:
			for cell : Cell in cell_row.row:
				cell.add_object(obj)
					
func show_cells() -> void:
	#for cell_plane : CellPlane in scene_cells:
		#for cell_row : CellRow in cell_plane.plane:
	for i in range(active_cells.size()):#cell_row.size()):
		var cell : Cell = active_cells[i]
		
		# Create a mesh for each cell
		var mesh_instance := MeshInstance3D.new()
		var box_mesh := BoxMesh.new()
		box_mesh.size = cell.aabb.size
		mesh_instance.mesh = box_mesh
		
		# Position at the center of the AABB
		mesh_instance.position = cell.aabb.get_center()
		
		# Create transparent colored material
		var material := StandardMaterial3D.new()
		material.albedo_color = Color.GREEN#Color(randf(), randf(), randf(), 1.0)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color.a = 0.5  # Make it transparent
		mesh_instance.material_override = material
		
		mesh_instance.name = "CellMesh"
		
		mesh_instance.add_to_group("cell_box")
		
		scene.parent_node.add_child.call_deferred(mesh_instance)

func find_player_cell(player_center : Vector3) -> void:
	#checking the adjacent cells first. 
	player_cell = null
	for cell : Cell in active_cells:
		if cell.aabb.has_point(player_center):
			player_cell = cell
			break
	#if player not there (such as initial load), check all cells.
	if player_cell == null:
		for cell_plane : CellPlane in scene_cells:
			for cell_row : CellRow in cell_plane.plane:
				for cell : Cell in cell_row.row:
					if cell.aabb.has_point(player_center):
						#cell_coords = cell.coords
						player_cell = cell
						break

func update_active_cells(initial_load : bool = false) -> void:
	if number_of_cells == 1 and !initial_load:
		print("NOT Loading in ", scene.name)
		#only 1 cell so no need to load/offload
		return
	if not scene.active: return
	print("YES loading in ", scene.name)
	var player_center : Vector3
	if initial_load:
		#player hasn't teleported into the scene yet,
		#but we still need to load the right cells
		player_center = ContentLoader.scene_teleport_pos
	else:
		ContentLoader.update_player_aabb()
		player_center = ContentLoader.player_aabb.get_center()
	find_player_cell(player_center)
	if player_cell == null:
		print("Player cell is null")
		return
	#assert(player_cell != null, "Player is not located in a content cell! Did they go outside the RoomArea?")
	var cell_coords : Vector3 = player_cell.coords
	var adjacent_cells : Array[Cell] = []
	find_adjacent_cells(adjacent_cells, cell_coords.x as int, cell_coords.y as int, cell_coords.z as int)
	
	#disable inactive cells
	for cell : Cell in active_cells:
		if !(cell in adjacent_cells):
			cell.set_active(false, initial_load) #offload
	
	#enable active cells
	for cell: Cell in adjacent_cells:
		cell.set_active(true, initial_load)
	
	active_cells = adjacent_cells
	scene.cell_debugger.update_active_cells()
	
func find_adjacent_cells(
	adjacent : Array[Cell],
	cell_plane_i : int, 
	cell_row_i : int, 
	cell_i : int) -> void:
	#check 3x3 cube
	for x in range(adjacent_range_min, adjacent_range_max):
		var new_plane_i : int = cell_plane_i + x
		if new_plane_i < 0 or new_plane_i >= WIDTH_DIVIDE:
			continue
		for y in range(adjacent_range_min, adjacent_range_max):
			var new_row_i : int = cell_row_i + y
			if new_row_i < 0 or new_row_i >= HEIGHT_DIVIDE:
				continue
			for z in range(adjacent_range_min, adjacent_range_max):
				var new_cell_i : int = cell_i + z
				if new_cell_i < 0 or new_cell_i >= DEPTH_DIVIDE:
					continue
				var cell : Cell = scene_cells[new_plane_i].plane[new_row_i].row[new_cell_i]
				adjacent.append(cell)
