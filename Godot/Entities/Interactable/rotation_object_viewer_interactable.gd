class_name ObjectViewerRotatable extends ObjectViewerInteractable

var dragging : bool = false

func _ready() -> void:
	print("Object viewer rotatatble")
	Interact.mouse_position_changed.connect(on_mouse_pos_changed)

func on_mouse_pos_changed(delta : Vector2):
	if !dragging:
		return
	self.rotate_x(delta.y * 0.005)
	self.rotate_y(delta.x * 0.005)

##INHERITED
func on_mouse_down() -> void:
	dragging = true
	
func on_mouse_up() -> void:
	dragging = false
