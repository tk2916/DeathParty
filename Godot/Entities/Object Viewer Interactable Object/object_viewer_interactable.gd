extends Area3D
class_name ObjectViewerInteractable

#The Object Viewer Interactable is class that can be inherited.
#Unlike the normal interactable, it assumes the item is being viewed on "Object Viewer" and thus
#the item MAY be rotatable. 

#The Object Viewer Interactable should ALWAYS be the child of a Node3D that it will manipulate.
#This is the "active item". Which should be it's immediate parent.

enum MOUSE_STATE {NONE, CLICK, DRAG}
var active_item : Node3D
@export var capture_drag : bool = true
@export var rotatable_object : bool = true

func _ready():
	active_item = get_parent()
	input_capture_on_drag = false

var pressed : bool = false
var mouse_in_object : bool = false

func _mouse_enter() -> void:
	mouse_in_object = true

func _mouse_exit() -> void:
	mouse_in_object = false


#TODO: Properly bind the inputs to the input map instead of manually checking for it in the code
func _input(event) -> void:
	#When the mouse moves if the button is clicked moves the item relative to the mouse movement
	if pressed and event is InputEventMouseMotion:
		if active_item != null:
			#NOTE: Rotation a bit sensitive, might want to try some manipulating
			active_item.rotate_x(event.relative.y * 0.005)
			active_item.rotate_y(event.relative.x * 0.005)

func _unhandled_input(event: InputEvent) -> void:
	pass

func _physics_process(delta : float) -> void:
	#TODO: Change this into an actual input 
	if Input.is_action_just_pressed("dialogic_default_action") and mouse_in_object:
		pressed = true
	if Input.is_action_just_released("dialogic_default_action"):
		pressed = false
