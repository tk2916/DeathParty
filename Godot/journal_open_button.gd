extends "res://Assets/GUIDesignScripts/default_gui_button.gd"

@onready var journal_open_sound : FmodEventEmitter2D = %JournalOpenSound
@onready var journal_close_sound : FmodEventEmitter2D = %JournalCloseSound


@export var journal_path : String
@export var journal : PackedScene

@export var object_viewer : Control

var journal_showing : bool = false

func _pressed() -> void:
	print("Journal button pressed")
	if journal_showing == false:
		object_viewer.set_item(journal_path)
		#object_viewer.camera_3d.projection = Camera3D.PROJECTION_ORTHOGONAL
		#object_viewer.camera_3d.size = 2.1
		journal_open_sound.play()
		object_viewer.visible = true
	else:
		journal_close_sound.play()
		object_viewer.visible = false
		#object_viewer.camera_3d.projection = Camera3D.PROJECTION_PERSPECTIVE
		object_viewer.remove_current_item()
	journal_showing = !journal_showing
