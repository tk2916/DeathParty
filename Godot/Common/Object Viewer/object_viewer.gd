class_name ObjectViewer extends Control

#The item that will be viewed by the object viewer
@export var active_item : Node3D
@export var rotate_off : bool = false
@export var parent : CanvasLayer

@export var test_path : String
var pressed : bool = false

@onready var sub_viewport : SubViewport = $SubViewportContainer/SubViewport
@onready var model_holder : Node3D =  $"SubViewportContainer/SubViewport/Model Holder"
@onready var camera_3d : Camera3D = $SubViewportContainer/SubViewport/Camera3D

#Custom background
@onready var color_rect : ColorRect = $ColorRect
@onready var blur : Panel = $Blur
@onready var custom_background_container : Control = $CustomBackground
@onready var item_info : ItemInfoContainer = $ItemInfo
@onready var exit_button_parent : Control = $ObjectViewerExit
@onready var exit_button : Button = $ObjectViewerExit/Button

@onready var journal_item_info : JournalItemInfo = $JournalItemInfo

var light_up_shader : ShaderMaterial = preload("res://Assets/Shaders/LightUpShader.tres")

var currently_open : bool = false

signal enabled

#Places the item into the viewport and defines the "item" variable
func set_item(item_path : String) -> void:
	var packed_scene : PackedScene = load(item_path)
	var scene : Node3D = packed_scene.instantiate()
	if scene == null:
		print("Scene Path not working")
		return
	set_item_properties(scene)

func set_preexisting_item(instance : Node3D) -> void:
	set_item_properties(instance)
	
func apply_shader_to_meshes_recursive(current_node : Node) -> void:
	if current_node is MeshInstance3D:
		var current_mesh : MeshInstance3D = current_node
		var current_material : Material = current_mesh.material_overlay
		if current_material == null:
			current_material = current_mesh.surface_get_material(0)
		if current_material == null:
			current_material = current_mesh.surface_get_material(1)
		if current_material == null:
			current_material = StandardMaterial3D.new()
		self.material_override = light_up_shader
		self.material_override.set_shader_parameter("albedo_texture", current_material.albedo_texture)
	var children : Array[Node] = current_node.get_children()
	if children.size() > 0:
		for child : Node in children:
			apply_shader_to_meshes_recursive(child)
	
func set_item_properties(scene : Node3D) -> Node3D:
	visible = true
	Interact.set_active_subviewport(sub_viewport)
	remove_current_item()
	
	model_holder.add_child(scene)

	active_item = scene
	parent.visible = true
	enabled.emit(true, camera_3d)
	return scene
	
func remove_current_item(remove_entirely : bool = true) -> void:
	parent.visible = false
	Interact.clear_active_subviewport()
	#Remove ALL items in the model holder
	enabled.emit(false, camera_3d)
	
	var children : Array = model_holder.get_children()
	if children.size() > 0:
		currently_open = true
	else:
		currently_open = false
	for child : Node in children:
		model_holder.remove_child(child)
		if remove_entirely and !(child is Journal):
			child.queue_free()
		
	active_item = null
	
func close_item_info() -> void:
	GuiSystem.inspecting_journal_item = false
	item_info.visible = false
	journal_item_info.visible = false
	exit_button_parent.visible = true

#TODO
#At origin, the object interferes with the world map. Need to move it away from the world map so that it's visible properly.
#Also need to assign object based on "item" variable not hard coded. 
func _ready() -> void:	
	#set_item(test_path)
	#camera_3d.transform.origin.y = camera_3d.transform.origin.y + hide_offset
	#camera_3d.transform.origin.z = camera_3d.transform.origin.z + hide_offset
	close_item_info()
	exit_button.pressed.connect(func():
		GuiSystem.hide_journal()
		remove_current_item()
		)

func zoom(factor : float) -> void:
	active_item.scale = active_item.scale*factor

func zoom_absolute(factor : float) -> void:
	active_item.scale = Vector3.ONE*factor

#Scroll in and out of item
func _input(event : InputEvent) -> void:
	if active_item == null: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed and Interact.grabbed_scroll_container == null:
			zoom(1.15)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed and Interact.grabbed_scroll_container == null:
			zoom(0.87)

#Resets the position of the item
func reset_item_position() -> void:
	if active_item:
		active_item.rotation.x = 0
		active_item.rotation.y = 0
	
func clear_custom_background() -> void:
	for child in custom_background_container.get_children():
		custom_background_container.remove_child(child)
		child.queue_free()
		
func set_background(scene : PackedScene = null) -> void:
	clear_custom_background()
	if scene:
		custom_background_container.add_child(scene.instantiate())
		
func view_item_info(item_resource : InventoryItemResource) -> void:
	item_info.set_text(item_resource.description)
	exit_button_parent.visible = false
	item_info.visible = true

func view_journal_item_info(journal_item_resource : JournalItemResource) -> void:
	journal_item_info.set_info(journal_item_resource)
	exit_button_parent.visible = false
	journal_item_info.visible = true
