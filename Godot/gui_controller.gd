class_name GuiController extends Node

var gui_dict : Dictionary[String, Control]
@export var journal_path : String
@export var object_viewer : Control

@onready var journal_open_sound : FmodEventEmitter2D = %JournalOpenSound
@onready var journal_close_sound : FmodEventEmitter2D = %JournalCloseSound

var journal_showing : bool = false

func _ready() -> void:
	var gui_objects : Array[Node] = get_tree().get_nodes_in_group("gui_object")
	for obj in gui_objects:
		gui_dict[obj.name] = obj
	
func close_all_guis():
	for key in gui_dict:
		gui_dict[key].visible = false

func show_journal():
	close_all_guis()
	object_viewer.set_item(journal_path)
	journal_open_sound.play()
	object_viewer.visible = true
	
func hide_journal():
	close_all_guis()
	journal_close_sound.play()
	object_viewer.visible = false
	object_viewer.remove_current_item()
	
func show_gui(name:String):
	close_all_guis()
	hide_journal()
	gui_dict[name].visible = true

func show_node(node:Control):
	close_all_guis()
	hide_journal()
	node.visible = true
