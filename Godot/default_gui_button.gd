extends Button

@export var show_element : Control

func _pressed() -> void:
	show_element.visible = !show_element.visible
