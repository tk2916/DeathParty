class_name ContentLoaderDebugMenu

var scene : LoadableScene
#CellUI
var active_cells_label : RichTextLabel
var cell_name_label : RichTextLabel
var scene_name_label : RichTextLabel
var item_name_label : RichTextLabel
var item_info_label : RichTextLabel
var grid_dimensions_label : RichTextLabel
var active_cell_label : RichTextLabel

var cell_vbox : VBoxContainer
var active_vbox : VBoxContainer
var inactive_vbox : VBoxContainer

var button_prefab : Button

var currently_shown_cell : int = -1
var currently_shown_obj : String = ""

var button_dict : Dictionary[int, Button] = {}
var mesh_dict : Dictionary[int, MeshInstance3D] = {}

func _init(_scene : LoadableScene) -> void:
	scene = _scene
	var control : Control = scene.instance.get_parent().get_node("CellVisualizer/Control")
	active_cells_label = control.get_node("ActiveCells")
	cell_name_label = control.get_node("CellName")
	scene_name_label = control.get_node("SceneName")
	item_name_label = control.get_node("ItemName")
	item_info_label = control.get_node("ItemInfoContainer/ItemInfo")
	grid_dimensions_label = control.get_node("GridDimensions")
	active_cell_label = control.get_node("ActiveCell")
	
	cell_vbox = control.get_node("Cells/VBox")
	active_vbox = control.get_node("Active/VBox")
	inactive_vbox = control.get_node("Inactive/VBox")
	
	button_prefab = control.get_node("Button")
	
func load_in() -> void:
	for child in cell_vbox.get_children():
		cell_vbox.remove_child(child)
		child.queue_free()
	clear_cell_objects()
	clear_obj_info()
	scene_name_label.text = "Scene: " + scene.name
	if !ContentLoader.cell_grids.has(scene.name):
		grid_dimensions_label.text = "Grid: 1 x 1 x 1"
	else:
		var grid_dimensions : Vector3 = ContentLoader.cell_grids[scene.scene_enum]
		grid_dimensions_label.text = (
			"Grid: " 
			+ str(int(grid_dimensions.x))
			+ " x " + str(int(grid_dimensions.y))
			+ " x " + str(int(grid_dimensions.z))
		)

func offload() -> void:
	#reset variables
	currently_shown_cell = -1
	currently_shown_obj = ""
	button_dict = {}

##CELL INFO ------------------------------------------
func clear_cell_objects() -> void:
	for child in active_vbox.get_children():
		active_vbox.remove_child(child)
		child.queue_free()
	for child in inactive_vbox.get_children():
		inactive_vbox.remove_child(child)
		child.queue_free()

func show_cell_objects(cell : Cell) -> void:
	currently_shown_cell = cell.id
	cell_name_label.text = "Now viewing: Cell " + str(cell.id)
	for obj : SceneObject in cell.loadable_objects:
		add_object(obj)

func create_debug_mesh(cell : Cell):
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
	return mesh_instance
	#scene.parent_node.add_child.call_deferred(mesh_instance)

func hide_all_meshes():
	for index : int in mesh_dict:
		var mesh : MeshInstance3D = mesh_dict[index]
		show_debug_mesh(index, false)

func show_debug_mesh(index : int, toggle : bool):
	var mesh_instance : MeshInstance3D = mesh_dict[index]
	if toggle:
		if !mesh_instance.is_inside_tree():
			scene.parent_node.add_child.call_deferred(mesh_instance)
	else:
		if mesh_instance.is_inside_tree():
			scene.parent_node.remove_child.call_deferred(mesh_instance)

func add_cell(cell : Cell) -> void:
	#debug mesh
	mesh_dict[cell.id] = create_debug_mesh(cell)
	
	#button
	var cell_button : Button = button_prefab.duplicate()
	cell_button.name = "Cell " + str(cell.id)
	cell_button.text = "Cell " + str(cell.id)
	cell_button.visible = true
	cell_vbox.add_child(cell_button)
	button_dict[cell.id] = cell_button
	
	cell_button.pressed.connect(func() -> void:
		clear_cell_objects()
		clear_obj_info()
		hide_all_meshes()
		if cell.id != currently_shown_cell:
			show_debug_mesh(cell.id, true)
			show_cell_objects(cell)
		else:
			currently_shown_cell = -1
		)

func update_cell(cell : Cell) -> void:
	var exists : bool = button_dict.has(cell.id)
	if !scene.active or not exists or !is_instance_valid(button_dict[cell.id]): return
	if cell.active:
		button_dict[cell.id].text = "[ON] Cell "+str(cell.id)
	else:
		button_dict[cell.id].text = "Cell "+str(cell.id)
	if currently_shown_cell == cell.id:
		clear_cell_objects()
		show_cell_objects(cell)

func update_active_cells() -> void:
	if !scene.active: return
	var active_cells : Array[Cell] = scene.cell_manager.active_cells
	var active_cells_str := "Active cells:"
	for cell : Cell in active_cells:
		active_cells_str = active_cells_str + " Cell" + str(cell.id) + ","
	
	active_cells_label.text = active_cells_str
	active_cell_label.text = "Player cell: Cell " + str(scene.cell_manager.player_cell.id)

##OBJ INFO ---------------------------------------
func clear_obj_info() -> void:
	item_name_label.text = ""
	item_info_label.text = ""
	
func show_obj_info(obj : SceneObject) -> void:
	currently_shown_obj = obj.name
	item_name_label.text = obj.name + ":"
	item_info_label.text = obj.info()

func add_object(obj : SceneObject) -> void:
	var obj_button : Button = button_prefab.duplicate()
	obj_button.text = obj.name
	obj_button.visible = true
	if obj.active:
		active_vbox.add_child(obj_button)
	else:
		inactive_vbox.add_child(obj_button)
	
	obj_button.pressed.connect(func() -> void:
		clear_obj_info()
		if obj.name != currently_shown_obj:
			show_obj_info(obj)
		else:
			currently_shown_obj = ""
		)
