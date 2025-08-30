extends Node

var object_viewer : ObjectViewer

func _ready() -> void:
	var main = get_tree().root.get_node_or_null("Main")
	if main == null: return
	
	object_viewer = main.get_node("ObjectViewerCanvasLayer/ObjectViewer")

func create_clickable_item(
	item_resource : InventoryItemResource, 
	item : Node3D = null
	) -> ObjectViewerInteractable:
	if item == null:
		item = item_resource.model.instantiate()
	var static_body : ObjectViewerInteractable
	if item.name.substr(0,8) == "polaroid":
		static_body = DragDropPolaroid.new(item_resource)
		#static_body.main_page = main_page
	else:
		static_body = ClickableInventoryItem.new(item_resource)
	
	var mesh_children : Array[Node] = Utils.get_descendants(item, [MeshInstance3D], false)
	for mesh : MeshInstance3D in mesh_children:
		fix_materials(mesh)
	
	print("STATIC BODY SCALE: ", static_body.scale)
	static_body.name = item_resource.name
	var collision_shape : CollisionShape3D = CollisionShape3D.new()
	collision_shape.name = "CollisionShape3D"
	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.extents = Vector3(.2,.5,.2)
	
	#static_body.global_position = item.global_position
	static_body.add_child(collision_shape)
	static_body.add_child(item)
	
	item.position = Vector3.ZERO
	item.rotate(Vector3(1,0,0), deg_to_rad(90))
	item.rotate(Vector3(0,1,0), deg_to_rad(180))
	
	return static_body

#When duplicating, materials get messed up
func fix_materials(mesh : MeshInstance3D):
	if not mesh.mesh: return
	if mesh.material_overlay: return
	# Fix materials from the original mesh's surfaces
	for i in range(mesh.mesh.get_surface_count()):
		var material = mesh.get_active_material(i)
		if material is BaseMaterial3D:
			var clone = material.duplicate()
			mesh.material_overlay = clone
			#clone.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
func show_item_details(
	item_resource : InventoryItemResource, 
	clickable_obj : ClickableInventoryItem = null
	) -> void:
	if clickable_obj == null:
		clickable_obj = create_clickable_item(item_resource)
	GuiSystem.hide_journal()
	var duplicate : ObjectViewerRotatable = ObjectViewerRotatable.new()
	for child in clickable_obj.get_children():
		if child is CollisionShape3D:
			child.disabled = false
		duplicate.add_child(child.duplicate())
	
	duplicate.scale = duplicate.scale*3
	#duplicate.rotate(Vector3(0,1,0), deg_to_rad(180.0))
	
	object_viewer.set_preexisting_item(duplicate)
	object_viewer.view_item_info(item_resource.name, item_resource.description)
