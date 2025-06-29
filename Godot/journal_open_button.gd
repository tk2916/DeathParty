extends "res://Assets/GUIDesignScripts/default_gui_button.gd"

@export var journal_path : String

@export var object_viewer : Control

#var journal_instance : Node = null
var journal_showing : bool = false

func _pressed() -> void:
	#show_element.visible = !show_element.visible
	if journal_showing == false:
		#journal_instance = journal.instantiate()
		object_viewer.set_item(journal_path)
	else:
		object_viewer.remove_current_item()
	journal_showing = !journal_showing
