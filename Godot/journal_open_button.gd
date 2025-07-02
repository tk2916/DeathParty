extends "res://Assets/GUIDesignScripts/default_gui_button.gd"

@export var journal_path : String
@export var journal : PackedScene

@export var object_viewer : Control
@onready var model_holder : Node3D = object_viewer.get_node("SubViewportContainer/SubViewport/Model Holder")

var journal_showing : bool = false

func _pressed() -> void:
	if journal_showing == false:
		object_viewer.set_item(journal_path)
		#model_holder.add_child(journal.instantiate())
		#object_viewer.camera_3d.projection = Camera3D.PROJECTION_ORTHOGONAL
		#object_viewer.camera_3d.size = 2.1
		object_viewer.visible = true
	else:
		object_viewer.visible = false
		object_viewer.camera_3d.projection = Camera3D.PROJECTION_PERSPECTIVE
		object_viewer.remove_current_item()
	journal_showing = !journal_showing
