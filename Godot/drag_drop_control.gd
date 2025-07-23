class_name DragDropControl extends ColorRect

@export var correct_item : InventoryItemResource

@onready var og_color : Color = color

func enter_hover() -> void:
	color = Color.RED
func exit_hover() -> void:
	color = og_color
	
func mouse_up(resource : InventoryItemResource, instance : DragDropPolaroid) -> void:
	if resource == correct_item:
		print("Correct model!")
		pass
	else:
		instance.return_to_og_position()
		pass
