class_name GuiButton extends Button

@export var show_element : Control

func _ready() -> void:
	mouse_default_cursor_shape = CURSOR_POINTING_HAND
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _pressed() -> void:
	if show_element:
		if !show_element.visible:
			GuiSystem.show_node(show_element)
		else:
			GuiSystem.hide_node(show_element)
		#else:
			#show_element.visible = !show_element.visible
