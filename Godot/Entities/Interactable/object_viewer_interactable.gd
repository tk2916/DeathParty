class_name ObjectViewerInteractable extends Node3D

#The interactable class is any object that is interactable. This means that if the mouse hovers over it
#it will become highlighted and the player can click on it to get some event
func _ready() -> void:
	$CollisionShape3D.set_collision_layer_value(9) #layer 9 is for interactables
#
##OVERRIDE THESE METHODS
func enter_hover() -> void:
	pass
func exit_hover() -> void:
	pass
func on_interact() -> void:
	pass
