extends Button

@export var show_element : Control

func _ready() -> void:
	mouse_default_cursor_shape = CURSOR_POINTING_HAND
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _pressed() -> void:
	show_element.visible = !show_element.visible
