extends Control

#The item that will be viewed by the object viewer
@export var item : MeshInstance3D
var pressed : bool = false

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var node_3d: Node3D = $SubViewportContainer/SubViewport/Node3D
@onready var camera_3d: Camera3D = $SubViewportContainer/SubViewport/Camera3D


#Places the item into the viewport and defines the "item" variable
func set_item(_item : MeshInstance3D):
	item = _item
	
	pass

#TODO
#At origin, the object interferes with the world map. Need to move it away from the world map so that it's visible properly.
#Also need to assign object based on "item" variable not hard coded. 
func _ready():
	node_3d.transform.origin.y = node_3d.transform.origin.y - 1000
	node_3d.transform.origin.z = node_3d.transform.origin.z - 1000
	camera_3d.transform.origin.y = camera_3d.transform.origin.y - 1000
	camera_3d.transform.origin.z = camera_3d.transform.origin.z - 1000
	
#Resets the position of the item
func reset_item_position():
	item.rotation.x = 0
	item.rotation.y = 0

func _input(event):
	#When the mouse moves if the button is clicked moves the item relative to the mouse movement
	if pressed and event is InputEventMouseMotion:
		item.rotation.x += event.relative.y * 0.005
		item.rotation.y += event.relative.x * 0.005
	
func _physics_process(delta : float) -> void:
	#TODO: Change this into an actual input 
	if Input.is_action_just_pressed("dialogic_default_action"):
		pressed = true
	if Input.is_action_just_released("dialogic_default_action"):
		pressed = false
	if Input.is_action_just_pressed("ui_cancel"):
		reset_item_position()
