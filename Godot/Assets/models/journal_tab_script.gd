extends StaticBody3D
class_name JournalTab

@export var text : String
@export var color : Color
@export var offset_distance : float = .2

@onready var up_direction : Vector3

var sub_viewport : Viewport
var button : Button

@export var flip_to_page : int

signal tab_pressed

func _ready() -> void:
	sub_viewport = $Tab/SubViewport
	button = sub_viewport.get_node("Button")
	button.text = text
	sub_viewport.pressed.connect(button_pressed)
	$Cube.get_surface_override_material(0).albedo_color = color
	sub_viewport.get_node("ColorRect").color = color

func return_to_original_pos():
	up_direction = -transform.basis.z.normalized()
	var offset = up_direction*offset_distance
	print("Moving down")
	global_position = global_position - offset	

func move_upward():
	up_direction = -transform.basis.z.normalized()
	var offset = up_direction*offset_distance
	print("Move upward")
	global_position = global_position + offset

func toggle_visible(tf : bool = !visible):
	visible = tf
	button.disabled = !tf
	
func button_pressed():
	print(self, " Pressed!")
	tab_pressed.emit()
	
func detected_input(event: InputEvent) -> void:
	print("Detected input: ", )
