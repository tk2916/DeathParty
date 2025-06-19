extends Control

#The item that will be viewed by the object viewer
@export var item : MeshInstance3D
var pressed : bool = false

#Places the item into the viewport and defines the "item" variable
func set_item(_item : MeshInstance3D):
	item = _item
	
	pass

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
