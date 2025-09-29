class_name InfoContainerGUI extends Control
@export var button : Button
@export var object_viewer : ObjectViewer

var show_inventory_on_close : bool = true

func _ready() -> void:
	button.pressed.connect(on_button_pressed)

func on_button_pressed() -> void:
	print("pressing exit")
	if DialogueSystem.in_dialogue: return
	object_viewer.close_item_info()
	GuiSystem.show_journal(show_inventory_on_close)
