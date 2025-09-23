class_name InfoContainerGUI extends Control
@export var button : Button
@export var object_viewer : ObjectViewer

func _ready() -> void:
	button.pressed.connect(on_button_pressed)

func on_button_pressed() -> void:
	if DialogueSystem.in_dialogue: return
	object_viewer.close_item_info()
	GuiSystem.show_journal(true)
