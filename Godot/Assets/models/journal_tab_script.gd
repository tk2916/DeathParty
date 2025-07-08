extends ObjectViewerInteractable
class_name JournalTab

@export var text : String
@export var color : Color
@export var offset_distance : float = .2
var og_rotation : Vector3
var default_rotation : Vector3 = Vector3(0,deg_to_rad(-180),0)

@onready var up_direction : Vector3

var sub_viewport : Viewport
var label : RichTextLabel

@export var flip_to_page : int

var disabled : bool = false

signal tab_pressed

func _ready() -> void:
	sub_viewport = $Tab/SubViewport
	label = sub_viewport.get_node("RichTextLabel")
	label.text = text
	#sub_viewport.pressed.connect(button_pressed)
	$Cube.get_surface_override_material(0).albedo_color = color
	sub_viewport.get_node("ColorRect").color = color
	og_rotation = rotation
	rotation = default_rotation

func return_to_original_pos():
	up_direction = -transform.basis.z.normalized()
	var offset = up_direction*offset_distance
	global_position = global_position - offset
	rotation = default_rotation

func move_upward():
	up_direction = -transform.basis.z.normalized()
	var offset = up_direction*offset_distance
	global_position = global_position + offset
	rotation = og_rotation

func toggle_visible(tf : bool = !visible):
	visible = tf
	disabled = !tf
	
func button_pressed():
	if disabled: return
	print(self, " Pressed!")
	tab_pressed.emit()

##INHERITED METHODS (OVERRIDDEN)
func enter_hover():
	pass
	#print("Entered tab hover: ", self.name)

func exit_hover():
	pass
	#print("Exited tab hover ", self.name)

func on_interact():
	button_pressed()
