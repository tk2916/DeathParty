extends Control

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


#Places the item into the viewport and defines the "item" variable
func set_item(item_path : String):	
	
	#Load scene
	var scene = load(item_path)
	if scene == null:
		print("Scene Path not working")
		return
	active_item = scene.instantiate()
	
	
	#Remove Current item and Place new active item
	remove_current_item()
	model_holder.add_child(active_item)
	active_item.transform.origin.y = active_item.transform.origin.y + hide_offset
	active_item.transform.origin.z = active_item.transform.origin.z + hide_offset
	

func remove_current_item():
	#Remove ALL items in the model holder
	for child in model_holder.get_children():
		model_holder.remove_child(child)
		child.queue_free()

#TODO
#At origin, the object interferes with the world map. Need to move it away from the world map so that it's visible properly.
#Also need to assign object based on "item" variable not hard coded. 
func _ready():	
	set_item(test_path)
	camera_3d.transform.origin.y = camera_3d.transform.origin.y + hide_offset
	camera_3d.transform.origin.z = camera_3d.transform.origin.z + hide_offset
	
#Resets the position of the item
func reset_item_position():
	active_item.rotation.x = 0
	active_item.rotation.y = 0

func _input(event):
	#When the mouse moves if the button is clicked moves the item relative to the mouse movement
	if pressed and event is InputEventMouseMotion:
		if active_item != null and !rotate_off:
			active_item.rotation.x += event.relative.y * 0.005
			active_item.rotation.y += event.relative.x * 0.005
	
func _physics_process(delta : float) -> void:
	#TODO: Change this into an actual input 
	if Input.is_action_just_pressed("dialogic_default_action"):
		pressed = true
	if Input.is_action_just_released("dialogic_default_action"):
		pressed = false
	if Input.is_action_just_pressed("ui_cancel"):
		reset_item_position()
