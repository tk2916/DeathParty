extends Node

var gui_dict: Dictionary[String, Control]
var journal: PackedScene = preload("res://Assets/models/bookflip_collisionbody.tscn")
var journal_instance: Journal
var object_viewer: ObjectViewer

var loading_screen: ColorRect
var loading_screen_visible := false # global var we can use to reject certain inputs etc while loading
var tree: SceneTree

##SOUNDS/ASSETS
var journal_open_sound: FmodEventEmitter2D
var journal_music: FmodEventEmitter3D
var journal_backpack_bg: PackedScene = preload("res://Assets/JournalTextures/backpack_background.tscn")

##STATES
var in_journal: bool = false
var inventory_showing: bool = false # used within journal scripts
var in_gui: bool = false
var in_phone: bool = false
var hid_phone_mid_convo: bool = false
var prevent_gui: bool = true

signal guis_closed

func _ready() -> void:
	tree = get_tree()
	var main: Node3D = tree.root.get_node_or_null("Main")
	if main == null: return
	
	journal_instance = journal.instantiate()
	
	journal_open_sound = journal_instance.get_node("Sounds/JournalOpenSound")
	journal_music = journal_instance.get_node("Sounds/JournalMusic")
	
	loading_screen = main.get_node("CanvasLayer/LoadingScreen")
	
	object_viewer = main.get_node("ObjectViewerCanvasLayer/ObjectViewer")
	var gui_objects: Array[Node] = tree.get_nodes_in_group("gui_object")
	for obj in gui_objects:
		gui_dict[obj.name] = obj

func set_gui_enabled(toggle: bool) -> void:
	prevent_gui = !toggle

func _physics_process(_delta: float) -> void:
	if prevent_gui or (DialogueSystem.in_dialogue and in_phone == false): return
	if Input.is_action_just_pressed("toggle_journal"):
		if in_journal:
			hide_journal()
		else:
			#var title_screen : CanvasLayer = get_tree().get_first_node_in_group("title_screen")
			#if title_screen != null and title_screen.visible == true:
				#return
			show_journal()

	elif Input.is_action_just_pressed("toggle_phone"):
		if in_phone:
			hide_phone()
		else:
			#var title_screen : CanvasLayer = get_tree().get_first_node_in_group("title_screen")
			#if title_screen != null and title_screen.visible == true:
				#return
			show_phone()

func close_all_guis() -> void:
	in_gui = false
	for key in gui_dict:
		gui_dict[key].visible = false

func check_for_open_guis() -> bool:
	var any_open_guis: bool = false
	for key in gui_dict:
		if gui_dict[key].visible:
			any_open_guis = true
			break
	return any_open_guis

func show_journal(inventory_open: bool = false) -> void:
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
	
func hide_journal() -> void:
	if not in_journal: return
	close_all_guis()
	Sounds.play_journal_close()
	journal_music.stop()
	FmodServer.set_global_parameter_by_name("InJournal", 0)
	object_viewer.visible = false
	object_viewer.remove_current_item(false)
	Interact.clear_active_subviewport()
	in_gui = false
	in_journal = false
	
	guis_closed.emit()

func journal_flip_to_page(page_number : int) -> void:
	if !in_journal: return
	journal_instance.bookflip.flip_to_page(page_number)

func inspect_journal_item(journal_item_rsc : JournalItemResource) -> void:
	object_viewer.view_journal_item_info(journal_item_rsc)

func show_phone(contact_resource: ChatResource = null) -> void:
	if contact_resource != null or hid_phone_mid_convo:
		#DialogueSystem.text_message_box.on_back_pressed()
		if contact_resource:
			#DialogueSystem.current_phone_resource = contact_resource
			DialogueSystem.text_message_box.on_contact_press(contact_resource)
		elif hid_phone_mid_convo:
			DialogueSystem.text_message_box.on_contact_press(DialogueSystem.current_phone_resource)
		hid_phone_mid_convo = false
		#DialogueSystem.start_text_convo(DialogueSystem.text_message_box, contact_name)
	show_gui("Phone")
	
func hide_phone() -> void:
	if DialogueSystem.are_choices: return
	#DialogueSystem.pause_text_convo(true)
	DialogueSystem.text_message_box.on_back_pressed()
	hide_gui("Phone")

func show_gui(gui_name: String) -> void:
	if gui_dict[gui_name].is_in_group("gui_object"):
		close_all_guis()
	hide_journal()
	gui_dict[gui_name].visible = true
	in_gui = true
	if gui_name == "Phone":
		in_phone = true

		# play the phone unlock sound
		var phone: Control = gui_dict[gui_name]
		var unlock_sound: FmodEventEmitter3D = phone.find_child("UnlockSound")
		if unlock_sound:
			unlock_sound.play()

func hide_gui(gui_name: String) -> void:
	gui_dict[gui_name].visible = false
	in_gui = check_for_open_guis()
	if gui_name == "Phone":
		in_phone = false

		# play the phone lock sound
		var phone: Control = gui_dict[gui_name]
		var lock_sound: FmodEventEmitter3D = phone.find_child("LockSound")
		if lock_sound:
			lock_sound.play()
	if !in_gui:
		guis_closed.emit()

func show_node(node: Control) -> void:
	if node.is_in_group("gui_object"):
		close_all_guis()
	hide_journal()
	node.visible = true
	in_gui = true
	
func hide_node(node: Control) -> void:
	node.visible = false
	in_gui = check_for_open_guis()
	if !in_gui:
		guis_closed.emit()

##LOADING SCREEN
func fade_loading_screen_in(fadeout_delay: float = 0) -> Tween:
	loading_screen_visible = true

	var tween: Tween = tree.create_tween()
	tween.tween_property(loading_screen, "modulate:a", 1, .2)
	if fadeout_delay > 0:
		tween.tween_callback(fade_loading_screen_out.bind(fadeout_delay))
	return tween
	
func fade_loading_screen_out(fadeout_delay: float = 0) -> Tween:
	if is_instance_valid(Globals.player) and Globals.player.is_inside_tree():
		Globals.player.movement_disabled = true
		await tree.create_timer(fadeout_delay).timeout
		Globals.player.movement_disabled = false
		loading_screen_visible = false
	var tween: Tween = tree.create_tween()
	tween.tween_property(loading_screen, "modulate:a", 0, 1)
	return tween
