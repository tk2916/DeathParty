extends StaticBody3D

@export var text : String
@export var color : Color

@onready var up_direction : Vector3

var sub_viewport : Viewport
var button : Button

@export var flip_to_page : int

func _ready() -> void:
	sub_viewport = $Tab/SubViewport
	button = sub_viewport.get_node("Button")
	button.text = text
	$Cube.get_surface_override_material(0).albedo_color = color
	sub_viewport.get_node("ColorRect").color = color

func return_to_original_pos():
	up_direction = -transform.basis.z.normalized()
	var offset = up_direction*.2
	print("Moving down")
	global_position = global_position - offset

func move_upward():
	up_direction = -transform.basis.z.normalized()
	var offset = up_direction*.2
	print("Move upward")
	global_position = global_position + offset
