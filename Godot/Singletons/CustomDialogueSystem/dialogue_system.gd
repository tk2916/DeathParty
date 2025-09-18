extends Node

## NODES
var main : Node3D
var canvas_layer : CanvasLayer
var text_message_box : MessageAppBox
var notification_box : VBoxContainer
var current_dialogue_box : DialogueBoxProperties

## RESOURCES
var current_phone_resource : ChatResource
var current_character_resource : TalkingObjectResource
var current_conversation : Array[InkLineInfo]

## STATES
var in_dialogue : bool = false
var are_choices : bool = false
var waiting : bool = false
signal done_waiting

## INK
var current_address : InkAddress:
	get: return Ink.address

## CONSTANTS or UTILITIES
const INK_FILE_PATH : String = "res://Assets/InkFiles/"
const INK_EXAMPLES_FILE_PATH : String = "res://Assets/InkExamples/"
var phone_notification_prefab : PackedScene = preload("res://phone_notification.tscn")
var dialogue_advance_sound: PackedScene = preload("res://Utilities/dialogue_advance_sound.tscn")
var new_message_sound_scene: PackedScene = preload("res://audio/new_message_sound.tscn") 
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
enum ANIMATION_STYLES {
	TYPEWRITER,
	NONE,
}
signal loaded_new_contact(contact : ChatResource)

## EMIT CONTACTS
func emit_contacts() -> void:
	for key in SaveSystem.active_save_file.phone_chats:
		loaded_new_contact.emit(SaveSystem.get_phone_chat(key))

## CONST PREFABS
const main_dialogue_box_prefab : PackedScene = preload("res://Assets/GUIPrefabs/DialogueBoxPrefabs/main_dialogue_box.tscn")

func _ready() -> void:
	await ContentLoader.finished_loading
	main = get_tree().root.get_node_or_null("Main")
	if main:
		canvas_layer = main.get_node("CanvasLayer")
		text_message_box = canvas_layer.get_node("Phone/Phone/Screen/Background/MessageApp")
		notification_box = canvas_layer.get_node("PhoneNotifications/VBoxContainer")

## START/PAUSE/END DIALOGUE
func show_dialogue_box(in_phone : bool) -> void:
	if not in_phone:
		spawn_dialogue_box()
	else:
		current_dialogue_box = text_message_box
	current_dialogue_box.visible = true

func begin_dialogue(file : JSON, in_phone : bool = false) -> void:
	assert(file != null, "You forgot to assign a JSON file!")
	if in_dialogue:
		pause_dialogue()
		#print("You can't start a new chat while in a dialogue!")
		return
	in_dialogue = true
	show_dialogue_box(in_phone)
	Ink.from_JSON(file)
	display_content()

func resume_dialogue(address : InkAddress) -> void:
	if in_dialogue:
		pause_dialogue()
		#print("You can't resume a chat while in a dialogue!")
		return
	in_dialogue = true
	show_dialogue_box(true)
	Ink.from_address(address)
	display_content()

func end_dialogue() -> void:
	print("End dialogue false")
	in_dialogue = false
	if current_dialogue_box == text_message_box: #if focused dialogue box is message app
		current_phone_resource.end_chat(current_conversation)
		current_phone_resource = null
	else:
		current_dialogue_box.visible = false
		current_dialogue_box.queue_free()
		if current_character_resource:
			current_character_resource.end_chat()
	current_conversation = []

func pause_dialogue(revert_address : bool = false) -> void: #ONLY FOR PHONE CONVERSATIONS
	if current_phone_resource == null or current_dialogue_box == null: return
	are_choices = false
	#GuiSystem.hid_phone_mid_convo = hiding_phone
	if revert_address:
		Ink.address.index -= 1
		current_conversation.pop_back()
	current_phone_resource.pause_chat(current_conversation) # stores Inky hierarchy
	in_dialogue = false
##

## LOAD CONTENT
func spawn_dialogue_box() -> void:
	var clone : Control = main_dialogue_box_prefab.instantiate()
	canvas_layer.add_child(clone)
	current_dialogue_box = clone

func load_json(json_file_name : String) -> JSON:
	if FileAccess.file_exists(INK_FILE_PATH+json_file_name):
		return load(INK_FILE_PATH+json_file_name)
	elif FileAccess.file_exists(INK_EXAMPLES_FILE_PATH+json_file_name):
		return load(INK_EXAMPLES_FILE_PATH+json_file_name)
	return null

func load_conversation(character_name : String, json_file_name : String) -> void:
	var json : JSON = load_json(json_file_name)
	var talking_resource : TalkingObjectResource = SaveSystem.get_character(character_name)
	if !talking_resource:
		talking_resource = SaveSystem.get_talking_object(character_name)
	talking_resource.load_chat(json)

func load_phone_conversation(chat_name : String, json_file_name : String) -> void:
	var json : JSON = load_json(json_file_name)
	var chat_resource : ChatResource = SaveSystem.get_phone_chat(chat_name)
	current_phone_resource = chat_resource
	chat_resource.load_chat(json)

func load_past_messages(past_chats : Array[InkLineInfo]) -> void:
	#print("Loading past messages: ", past_chats)
	current_dialogue_box = text_message_box
	current_conversation = past_chats
	for n in range(current_conversation.size()):
		var chat : InkLineInfo = current_conversation[n]
		current_dialogue_box.add_line(chat, true)

func to_phone(chat_name : String, file : JSON) -> void: # called to load json into phone
	var chat : ChatResource = SaveSystem.get_phone_chat(chat_name)
	current_phone_resource = chat
	current_phone_resource.load_chat(file)

func from_character(char_rsc : TalkingObjectResource, file : JSON) -> void:
	current_character_resource = char_rsc
	begin_dialogue(file)
##

## PROCESS CONTENT
func get_first_message(json : JSON) -> InkLineInfo:
	return Ink.get_first_message(json)

func display_content() -> void:
	var content : Variant = Ink.get_content()
	'''
	Ink.get_content() returns Array[InkNode]
	InkNode can be InkLineInfo or InkChoiceInfo
	'''
	if content[0] is InkLineInfo:
		var line : InkLineInfo = content[0]
		if line.speaker == "System" and line.text == "end":
			print("Ended dialogue")
			end_dialogue()
		elif line.text[0] == "/":
			await match_command(line.text)
			display_content()
		else:
			current_dialogue_box.add_line(line)
			current_conversation.push_back(line)
	elif content[0] is InkChoiceInfo:
		var choices : Array[InkChoiceInfo] = []
		for choice : InkChoiceInfo in content:
			choices.push_back(choice)
		are_choices = true
		current_dialogue_box.set_choices(choices)

## PROCESS COMMANDS
func match_command(text_ : String) -> void:
	#break up command into parameters
	var parameters_array : Array[String]
	var current_parameter : String = ""
	var within_quotations : bool = false
	for character in text_:
		if character == "\"":
			within_quotations = !within_quotations
			continue
		elif !within_quotations:
			if character == " ":
				parameters_array.push_back(current_parameter)
				current_parameter = ""
				continue
		current_parameter += character
	parameters_array.push_back(current_parameter)
	print("Parameters array: ", parameters_array)
	#match the first parameters (the command)
	match(parameters_array[0]):
		"/give_item":
			waiting = true
			SaveSystem.add_item(parameters_array[1], true)
			'''
			set this automatically so writers don't have to keep
			writing /give_item and /has_item right after each other
			'''
			SaveSystem.set_key("has_item_flag", true)
			current_dialogue_box.visible = false
			await GuiSystem.guis_closed
			waiting = false
			current_dialogue_box.visible = true
		"/remove_item":
			#alerts if you don't have enough items
			var result : int = SaveSystem.remove_item(parameters_array[1])
			if result == 0:
				SaveSystem.set_key("remove_item_flag", false)
			else:
				SaveSystem.set_key("remove_item_flag", true)
		"/has_item":
			var result : int = SaveSystem.item_count(parameters_array[1])
			var tf_result : bool = true
			if result == 0: #does not have item
				print("User does not have item: ", parameters_array[1])
				tf_result = false
			else:
				print("User has item: ", parameters_array[1])
			SaveSystem.set_key("has_item_flag", tf_result)
			if parameters_array.size() >= 3:
				#writers can set a custom variable to store the results in
				var custom_var : String = parameters_array[2]
				SaveSystem.set_key(custom_var, tf_result)
		"/give_task":
			SaveSystem.add_task(parameters_array[1])
		"/complete_task":
			SaveSystem.complete_task(parameters_array[1])
		"/load_chat":
			load_conversation(parameters_array[1], parameters_array[2])
		"/load_phone_chat":
			load_phone_conversation(parameters_array[1], parameters_array[2])
		"/die_roll":
			var stat : String = parameters_array[1].to_lower()
			var difficulty : String = parameters_array[2].to_lower()
			var roll : int = rng.randi_range(1,20) #20-sided die
			var modified_roll : int = roll + (SaveSystem.get_key(stat)-10)
			var threshold : int = 0
			match(difficulty):
				"hard":
					threshold = 17
				"medium":
					threshold = 13
				"easy":
					threshold = 10
			print("Die roll!: ", modified_roll)
			if modified_roll >= threshold:
				SaveSystem.set_key("die_roll_flag", true)
			else:
				SaveSystem.set_key("die_roll_flag", false)
		"/change_location":
			var target_resource : CharacterResource = SaveSystem.get_character(parameters_array[1])
			var target_location : String = parameters_array[2]
			target_resource.change_location(target_location)
		"/fade_screen":
			if parameters_array[1] == "true":
				current_dialogue_box.visible = false
				GuiSystem.fade_loading_screen_in()
			elif parameters_array[1] == "false":
				var tween : Tween = await GuiSystem.fade_loading_screen_out()
				await tween.finished
				current_dialogue_box.visible = true
		"/toggle_ui":
			if parameters_array[1] == "true":
				current_dialogue_box.visible = true
			elif parameters_array[1] == "false":
				current_dialogue_box.visible = false
		"/wait":
			waiting = true
			var wait_time : float = float(parameters_array[1])
			await get_tree().create_timer(wait_time).timeout
			waiting = false
			done_waiting.emit()
		"/play_animation": ##WIP
			var character_name : String = parameters_array[1]
			var animation_name : String = parameters_array[2]
			print("Playing animation ", character_name, " for ", animation_name)
			var npc_model : NPC = ContentLoader.get_active_npc(character_name).npc
			if npc_model:
				npc_model.play_animation(animation_name)

## ADVANCE DIALOGUE
func skip() -> void:
	current_dialogue_box.skip()

func advance_dialogue() -> void:
	print("Trying to advance dialogue: ", !in_dialogue, !is_instance_valid(current_dialogue_box), are_choices, waiting)
	if (
		!in_dialogue
		or !is_instance_valid(current_dialogue_box)
		or are_choices
		or waiting
	): return	

	if (
		current_dialogue_box.done_state == true
	):
		display_content()
		
	else:
		skip()

	if not GuiSystem.in_phone:
		var dialogue_advance_sound_instance: FmodEventEmitter3D = dialogue_advance_sound.instantiate()
		main.add_child(dialogue_advance_sound_instance)

## MAKE CHOICE
func make_choice(redirect:String) -> void:
	are_choices = false
	print("Making choice: ", redirect)
	Ink.make_choice(redirect)
	display_content()