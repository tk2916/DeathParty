extends Node

var gui_dict : Dictionary[String, Control]
var journal : PackedScene = preload("res://Assets/models/bookflip_collisionbody.tscn")
var journal_instance : Journal
var object_viewer : ObjectViewer

var journal_open_sound : FmodEventEmitter2D
var journal_close_sound : FmodEventEmitter2D

var in_journal : bool = false
var in_gui : bool = false

func _ready() -> void:
	var main = get_tree().root.get_node_or_null("Main")
	if main == null: return
	
	journal_instance = journal.instantiate()
	
	journal_open_sound = journal_instance.get_node("Sounds/JournalOpenSound")
	journal_close_sound = journal_instance.get_node("Sounds/JournalCloseSound")
	
	object_viewer = main.get_node("ObjectViewer")
	var gui_objects : Array[Node] = get_tree().get_nodes_in_group("gui_object")
	for obj in gui_objects:
		gui_dict[obj.name] = obj
	
func close_all_guis():
	in_gui = false
	for key in gui_dict:
		gui_dict[key].visible = false

func check_for_open_guis():
	var any_open_guis : bool = false
	for key in gui_dict:
		if gui_dict[key].visible:
			any_open_guis = true
			break
	return any_open_guis

func show_journal():
	close_all_guis()
	print("Setting journal: ", journal_instance.position)
	object_viewer.set_preexisting_item(journal_instance)
	journal_open_sound.play()
	object_viewer.visible = true
	in_gui = true
	in_journal = true
	
func hide_journal():
	if not in_journal: return
	close_all_guis()
	journal_close_sound.play()
	object_viewer.visible = false
	object_viewer.remove_current_item(false)
	in_gui = false
	in_journal = false
	
func show_gui(name:String):
	if gui_dict[name].is_in_group("gui_object"):
		close_all_guis()
	hide_journal()
	gui_dict[name].visible = true
	in_gui = true
	
func hide_gui(name:String):
	gui_dict[name].visible = false
	in_gui = check_for_open_guis()

func show_node(node:Control):
	if node.is_in_group("gui_object"):
		close_all_guis()
	hide_journal()
	node.visible = true
	in_gui = true
	
func hide_node(node:Control):
	node.visible = false
	in_gui = check_for_open_guis()
