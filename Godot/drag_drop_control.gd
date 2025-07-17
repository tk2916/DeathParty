class_name DragDropControl extends ColorRect

@export var correct_model : PackedScene

@onready var og_color : Color = color

func enter_hover() -> void:
	color = Color.RED
func exit_hover() -> void:
	color = og_color
func mouse_up(model : PackedScene) -> void:
	if model == correct_model:
		pass
	else:
		pass
