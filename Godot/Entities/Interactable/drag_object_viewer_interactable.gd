class_name ObjectViewerDraggable extends ObjectViewerInteractable

var dragging : bool = false
@export var constrain_x : bool = false
@export var constrain_y : bool = false

var local_y_dir : Vector3
var local_x_dir : Vector3

func _ready() -> void:
	Interact.mouse_position_changed.connect(on_mouse_pos_changed)

func on_mouse_pos_changed(delta : Vector2):
	if !dragging:
		return
	##DO NOT CHANGE: these look wacky but they are right
	if not constrain_y:
		local_y_dir = global_transform.basis.y.normalized()
		var offset = local_y_dir * 0.005 * -delta.y
		self.global_position = global_position + offset
	if not constrain_x:
		local_x_dir = global_transform.basis.x.normalized()
		var offset = local_x_dir * 0.005 * -delta.x
		self.global_position = global_position + offset

##INHERITED
func on_mouse_down() -> void:
	dragging = true
	
func on_mouse_up() -> void:
	dragging = false
