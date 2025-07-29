class_name ThreeDGUI extends Control

var hovering : bool = false

func enter_hover() -> void:
	hovering = true
	
func exit_hover() -> void:
	hovering = false

func on_mouse_down() -> void:
	pass

func on_mouse_up() -> void:
	pass
	
