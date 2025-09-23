class_name ObjectViewerInteractable extends Area3D

#The interactable class is any object that is interactable. This means that if the mouse hovers over it
#it will become highlighted and the player can click on it to get some event
func _init() -> void:
	self.set_collision_layer_value(1, true)
	self.set_collision_layer_value(4, true)
#
##OVERRIDE THESE METHODS
func enter_hover() -> void:
	pass
func exit_hover() -> void:
	pass
func on_mouse_down() -> void:
	pass
func on_mouse_up() -> void:
	pass
