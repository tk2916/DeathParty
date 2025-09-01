extends Node

var gui_dict : Dictionary[String, Control]
var journal : PackedScene = preload("res://Assets/models/bookflip_collisionbody.tscn")
var journal_instance : Journal
var object_viewer : ObjectViewer

var journal_open_sound : FmodEventEmitter2D
var journal_close_sound : FmodEventEmitter2D
var journal_music : FmodEventEmitter3D
var journal_backpack_bg : PackedScene = preload("res://Assets/JournalTextures/backpack_background.tscn")

var in_journal : bool = false
var inventory_showing : bool = false #used within journal scripts
var in_gui : bool = false
var in_phone : bool = false

func _ready() -> void:
	var main = get_tree().root.get_node_or_null("Main")
	if main == null: return
	
	journal_instance = journal.instantiate()
	
	journal_open_sound = journal_instance.get_node("Sounds/JournalOpenSound")
	journal_close_sound = journal_instance.get_node("Sounds/JournalCloseSound")
	journal_music = journal_instance.get_node("Sounds/JournalMusic")
	
	object_viewer = main.get_node("ObjectViewerCanvasLayer/ObjectViewer")
	var gui_objects : Array[Node] = get_tree().get_nodes_in_group("gui_object")
	for obj in gui_objects:
		gui_dict[obj.name] = obj


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_journal"):
		if in_journal:
			hide_journal()
		else:
			if get_tree().get_first_node_in_group("title_screen").visible == true:
				return
			show_journal()

	elif Input.is_action_just_pressed("toggle_phone"):
		if in_phone:
			hide_gui("Phone")
		else:
			if get_tree().get_first_node_in_group("title_screen").visible == true:
				return
			show_gui("Phone")


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

func show_journal(inventory_open : bool = false):
	close_all_guis()
	journal_instance.reset_properties()
	inventory_showing = false
	object_viewer.set_preexisting_item(journal_instance)
	Interact.set_active_subviewport(journal_instance.bookflip.page1_subviewport)
	if inventory_open:
		journal_instance.show_inventory()
	journal_open_sound.play()
	journal_music.find_child("MusicTimer").start()
	FmodServer.set_global_parameter_by_name("InJournal", 1)
	object_viewer.visible = true
	in_gui = true
	in_journal = true
	
func hide_journal():
	if not in_journal: return
	close_all_guis()
	journal_close_sound.play()
	journal_music.stop()
	FmodServer.set_global_parameter_by_name("InJournal", 0)
	object_viewer.visible = false
	object_viewer.remove_current_item(false)
	Interact.clear_active_subviewport()
	in_gui = false
	in_journal = false


func show_gui(name:String):
	if gui_dict[name].is_in_group("gui_object"):
		close_all_guis()
	hide_journal()
	gui_dict[name].visible = true
	in_gui = true
	if name == "Phone":
		in_phone = true

		# play the phone unlock sound
		var phone: Control = get_tree().get_first_node_in_group("phone")
		var unlock_sound: FmodEventEmitter3D = phone.find_child("UnlockSound")
		if unlock_sound:
			unlock_sound.play()


func hide_gui(name:String):
	gui_dict[name].visible = false
	in_gui = check_for_open_guis()
	if name == "Phone":
		in_phone = false

		# play the phone lock sound
		var phone: Control = get_tree().get_first_node_in_group("phone")
		var lock_sound: FmodEventEmitter3D = phone.find_child("LockSound")
		if lock_sound:
			lock_sound.play()


func show_node(node:Control):
	if node.is_in_group("gui_object"):
		close_all_guis()
	hide_journal()
	node.visible = true
	in_gui = true
	
func hide_node(node:Control):
	node.visible = false
	in_gui = check_for_open_guis()
