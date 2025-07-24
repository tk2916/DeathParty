class_name GuiButton extends Button

@export var show_element : Control
@export var gui_controller : GuiController

func _ready() -> void:
	mouse_default_cursor_shape = CURSOR_POINTING_HAND
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _pressed() -> void:
	if show_element:
		if gui_controller:
			if !show_element.visible:
				gui_controller.show_node(show_element)
			else:
				show_element.visible = false
		else:
			show_element.visible = !show_element.visible
