class_name ObjectViewer extends Control

#The item that will be viewed by the object viewer
@export var active_item : Node3D
@export var rotate_off : bool = false

@export var test_path : String
var pressed : bool = false

#Moves the item and camara offscreen by pushing it by a large offset
@export var hide_offset : int = -1000

@onready var sub_viewport : SubViewport = $SubViewportContainer/SubViewport
@onready var model_holder : Node3D =  $"SubViewportContainer/SubViewport/Model Holder"
@onready var camera_3d : Camera3D = $SubViewportContainer/SubViewport/Camera3D

var currently_open : bool = false

signal enabled

#Places the item into the viewport and defines the "item" variable
func set_item(item_path : String) -> void:
	active_item = set_item_inactive(item_path)

func set_preexisting_item(instance : Node3D, active : bool = false) -> void:
	var scene : Node3D = set_item_properties(instance)
	if active:
		active_item = scene

func set_item_inactive(item_path : String) -> Node3D:
	var scene : Node = load(item_path).instantiate()
	if scene == null:
		print("Scene Path not working")
		return
	return set_item_properties(scene)
	
func set_item_properties(scene : Node3D) -> Node3D:
	Interact.set_active_subviewport(sub_viewport)
	remove_current_item()
	#if !currently_open:
	scene.transform.origin.y = scene.transform.origin.y + hide_offset
	scene.transform.origin.z = scene.transform.origin.z + hide_offset
	model_holder.add_child(scene)
	print("Model holder children: ", model_holder.get_children())
	enabled.emit(true, camera_3d)
	return scene
	
func remove_current_item() -> void:
	print("Removing current item")
	Interact.clear_active_subviewport()
	#Remove ALL items in the model holder
	enabled.emit(false, camera_3d)
	
	var children = model_holder.get_children()
	if children.size() > 0:
		currently_open = true
	else:
		currently_open = false
	for child in children:
		model_holder.remove_child(child)
		child.queue_free()

#TODO
#At origin, the object interferes with the world map. Need to move it away from the world map so that it's visible properly.
#Also need to assign object based on "item" variable not hard coded. 
func _ready() -> void:	
	#set_item(test_path)
	camera_3d.transform.origin.y = camera_3d.transform.origin.y + hide_offset
	camera_3d.transform.origin.z = camera_3d.transform.origin.z + hide_offset
	
#Resets the position of the item
func reset_item_position() -> void:
	if active_item:
		active_item.rotation.x = 0
		active_item.rotation.y = 0
