extends Control

func _ready() -> void:
	for child : Control in self.find_children("*", "", true, false):
		custom_minimum_size.y += child.custom_minimum_size.y
		
	print("Final minimum size: ", custom_minimum_size.y)
