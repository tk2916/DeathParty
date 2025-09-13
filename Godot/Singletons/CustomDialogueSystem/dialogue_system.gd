extends Node

## NODES
var main: Node3D
var canvas_layer: CanvasLayer
var text_message_box: MessageAppBox
var notification_box: VBoxContainer
var current_dialogue_box: DialogueBoxProperties

## RESOURCES
var current_phone_resource: ChatResource
var current_character_resource: CharacterResource
var current_conversation: Array[InkLineInfo]

## STATES
var in_dialogue: bool = false
var are_choices: bool = false
var waiting: bool = false
signal done_waiting

## INK
var current_address: InkAddress:
	get: return Ink.address

## CONSTANTS or UTILITIES
const INK_FILE_PATH: String = "res://Assets/InkFiles/"
const INK_EXAMPLES_FILE_PATH: String = "res://Assets/InkExamples/"
var phone_notification_prefab: PackedScene = preload("res://phone_notification.tscn")
var dialogue_advance_sound: PackedScene = preload("res://Utilities/dialogue_advance_sound.tscn")
var new_message_sound_scene: PackedScene = preload("res://audio/new_message_sound.tscn")
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
enum ANIMATION_STYLES {
	TYPEWRITER,
	NONE,
}
signal loaded_new_contact(contact: ChatResource)

## EMIT CONTACTS
func emit_contacts() -> void:
	for key in SaveSystem.active_save_file.phone_chats:
		loaded_new_contact.emit(SaveSystem.get_phone_chat(key))

## CONST PREFABS
const main_dialogue_box_prefab: PackedScene = preload("res://Assets/GUIPrefabs/DialogueBoxPrefabs/main_dialogue_box.tscn")

func _ready() -> void:
	await ContentLoader.finished_loading
	main = get_tree().root.get_node_or_null("Main")
	if main:
		canvas_layer = main.get_node("CanvasLayer")
		text_message_box = canvas_layer.get_node("Phone/Phone/Screen/Background/MessageApp")
		notification_box = canvas_layer.get_node("PhoneNotifications/VBoxContainer")

## START/PAUSE/END DIALOGUE
func show_dialogue_box(in_phone: bool) -> void:
	if not in_phone:
		spawn_dialogue_box()
	else:
		current_dialogue_box = text_message_box
	current_dialogue_box.visible = true

func begin_dialogue(file: JSON, in_phone: bool = false) -> void:
	assert(file != null, "You forgot to assign a JSON file!")
	if in_dialogue:
		print("You can't start a new chat while in a dialogue!")
		return
	in_dialogue = true
	show_dialogue_box(in_phone)
	Ink.from_JSON(file)
	display_content()

func resume_dialogue(address: InkAddress) -> void:
	if in_dialogue:
		print("You can't resume a chat while in a dialogue!")
		return
	show_dialogue_box(true)
	Ink.from_address(address)
	display_content()

func end_dialogue() -> void:
	in_dialogue = false
	if current_dialogue_box == text_message_box: # if focused dialogue box is message app
		current_phone_resource.end_chat(current_conversation)
		current_phone_resource = null
	else:
		current_dialogue_box.visible = false
		current_dialogue_box.queue_free()
		if current_character_resource:
			current_character_resource.end_chat()
	current_conversation = []

func pause_dialogue() -> void: # ONLY FOR PHONE CONVERSATIONS
	if current_phone_resource == null or current_dialogue_box == null: return
	#GuiSystem.hid_phone_mid_convo = hiding_phone
	current_phone_resource.pause_chat(current_conversation) # stores Inky hierarchy
	in_dialogue = false
##

## LOAD CONTENT
func spawn_dialogue_box() -> void:
	var clone: Control = main_dialogue_box_prefab.instantiate()
	canvas_layer.add_child(clone)
	current_dialogue_box = clone

func load_json(json_file_name: String) -> JSON:
	if FileAccess.file_exists(INK_FILE_PATH + json_file_name):
		return load(INK_FILE_PATH + json_file_name)
	elif FileAccess.file_exists(INK_EXAMPLES_FILE_PATH + json_file_name):
		return load(INK_EXAMPLES_FILE_PATH + json_file_name)
	return null

func load_conversation(character_name: String, json_file_name: String) -> void:
	var json: JSON = load_json(json_file_name)
	var char_resource: CharacterResource = SaveSystem.get_character(character_name)
	char_resource.load_chat(json)

func load_phone_conversation(chat_name: String, json_file_name: String) -> void:
	var json: JSON = load_json(json_file_name)
	var chat_resource: ChatResource = SaveSystem.get_phone_chat(chat_name)
	current_phone_resource = chat_resource
	chat_resource.load_chat(json)

func load_past_messages(past_chats: Array[InkLineInfo]) -> void:
	#print("Loading past messages: ", past_chats)
	current_conversation = past_chats
	for n in range(current_conversation.size()):
		var chat: InkLineInfo = current_conversation[n]
		current_dialogue_box.add_line(chat)

func to_phone(chat_name: String, file: JSON) -> void: # called to load json into phone
	var chat: ChatResource = SaveSystem.get_phone_chat(chat_name)
	current_phone_resource = chat
	current_phone_resource.load_chat(file)

func from_character(char_rsc: CharacterResource, file: JSON) -> void:
	current_character_resource = char_rsc
	begin_dialogue(file)
##

## PROCESS CONTENT
func get_first_message(json: JSON) -> InkLineInfo:
	return Ink.get_first_message(json)

func display_content() -> void:
	var content: Variant = Ink.get_content()
	'''
	Ink.get_content() returns Array[InkNode]
	InkNode can be InkLineInfo or InkChoiceInfo
	'''
	if content[0] is InkLineInfo:
		var line: InkLineInfo = content[0]
		if line.speaker == "System" and line.text == "end":
			end_dialogue()
		elif line.text[0] == "/":
			await match_command(line.text)
			display_content()
		else:
			current_conversation.push_back(line)
			current_dialogue_box.add_line(line)
	elif content[0] is InkChoiceInfo:
		var choices: Array[InkChoiceInfo] = []
		for choice: InkChoiceInfo in content:
			choices.push_back(choice)
		are_choices = true
		current_dialogue_box.set_choices(choices)

## PROCESS COMMANDS
func match_command(text_: String) -> void:
	#break up command into parameters
	var parameters_array: Array[String]
	var current_parameter: String = ""
	var within_quotations: bool = false
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
	match (parameters_array[0]):
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
			var result: int = SaveSystem.remove_item(parameters_array[1])
			if result == 0:
				SaveSystem.set_key("remove_item_flag", false)
			else:
				SaveSystem.set_key("remove_item_flag", true)
		"/has_item":
			var result: int = SaveSystem.item_count(parameters_array[1])
			var tf_result: bool = true
			if result == 0: # does not have item
				print("User does not have item: ", parameters_array[1])
				tf_result = false
			else:
				print("User has item: ", parameters_array[1])
			SaveSystem.set_key("has_item_flag", tf_result)
			if parameters_array.size() >= 3:
				#writers can set a custom variable to store the results in
				var custom_var: String = parameters_array[2]
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
			var stat: String = parameters_array[1].to_lower()
			var difficulty: String = parameters_array[2].to_lower()
			var roll: int = rng.randi_range(1, 20) # 20-sided die
			var modified_roll: int = roll + (SaveSystem.get_key(stat) - 10)
			var threshold: int = 0
			match (difficulty):
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
			var target_resource: CharacterResource = SaveSystem.get_character(parameters_array[1])
			var target_location: String = parameters_array[2]
			target_resource.change_location(target_location)
		"/fade_screen":
			if parameters_array[1] == "true":
				current_dialogue_box.visible = false
				GuiSystem.fade_loading_screen_in()
			elif parameters_array[1] == "false":
				var tween: Tween = await GuiSystem.fade_loading_screen_out()
				await tween.finished
				current_dialogue_box.visible = true
		"/toggle_ui":
			if parameters_array[1] == "true":
				current_dialogue_box.visible = true
			elif parameters_array[1] == "false":
				current_dialogue_box.visible = false
		"/wait":
			waiting = true
			var wait_time: float = float(parameters_array[1])
			await get_tree().create_timer(wait_time).timeout
			waiting = false
			done_waiting.emit()
		"/play_animation": ## WIP
			var character_name: String = parameters_array[1]
			var animation_name: String = parameters_array[2]
			print("Playing animation ", character_name, " for ", animation_name)
			var npc_model: NPC = ContentLoader.get_active_npc(character_name).npc
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

#CLICK TO ADVANCE DIALOGUE
var pressed: bool = false

func _process(_delta: float) -> void:
	if (Input.is_action_pressed("dialogic_default_action")):
		if !pressed:
			advance_dialogue()
			pressed = true
	else:
		pressed = false
## MAKE CHOICE
func make_choice(redirect: String) -> void:
	are_choices = false
	print("Making choice: ", redirect)
	Ink.make_choice(redirect)
	display_content()

# var main : Node
# var canvas_layer : CanvasLayer
# var text_message_box : MessageAppBox

# #For chats
# var phone_notification_prefab : PackedScene = preload("res://phone_notification.tscn")
# var notification_box : VBoxContainer
# #

# var waiting : bool = false
# var mouse_contained_within_gui : bool = true

# var dialogue_advance_sound: PackedScene = preload("res://Utilities/dialogue_advance_sound.tscn")
# var new_message_sound_scene: PackedScene = preload("res://audio/new_message_sound.tscn")

# func _ready() -> void:
# 	await ContentLoader.finished_loading
# 	main = get_tree().root.get_node_or_null("Main")
# 	if main:
# 		canvas_layer = main.get_node("CanvasLayer")
# 		text_message_box = canvas_layer.get_node("Phone/Phone/Screen/Background/MessageApp")
# 		notification_box = canvas_layer.get_node("PhoneNotifications/VBoxContainer")
# 		print("Found text message box: ", text_message_box)

# const INK_FILE_PATH : String = "res://Assets/InkExamples/"
# var in_dialogue : bool = false #other scripts check this

# #DIALOGUE BOX PROPERTIES
# var dialogue_container : BoxContainer
# var choice_container : BoxContainer
# var image_container : TextureRect
# var name_container : RichTextLabel

# var dialogue_box_properties : DialogueBoxResource
# var dialogue_box_id : int
# var current_dialogue_box : Control

# #DIALOGUES (FULL CHARACTER SENTENCES)
# var all_dialogues : Array[InkLineInfo] = []
# var current_dialogue_index : int = 0

# #LINES
# var current_line_label : DialogueLine

# #CHOICES
# var are_choices : bool = false
# var current_choices : Array
# var current_choice_labels : Array[Node]

# #CHARACTER RESOURCE
# var current_character_resource : CharacterResource = null

# #PHONE CONVERSATIONS CAN BE PAUSED AND RETURNED TO
# var current_phone_resource : ChatResource = null
# var current_conversation : Array[InkLineInfo]
# var current_address : InkAddress :
# 	get: return Ink.address

# #RANDOM NUMBERS (for dice rolls)
# var rng : RandomNumberGenerator = RandomNumberGenerator.new()

# #CONTACTS (phone)
# signal loaded_new_contact
# signal done_waiting

# func emit_contacts() -> void:
# 	for key in SaveSystem.active_save_file.phone_chats:
# 		loaded_new_contact.emit(SaveSystem.get_phone_chat(key))

# #in case we want to switch dialogue box mid conversation
# func mouse_entered() -> void:
# 	mouse_contained_within_gui = true
# func mouse_exited() -> void:
# 	mouse_contained_within_gui = false

# func transferBoxProperties() -> void:
# 	mouse_contained_within_gui = true
# 	var properties : DialogueBoxProperties = current_dialogue_box
# 	dialogue_container = properties.dialogue_container
# 	choice_container = properties.choice_container
# 	image_container = properties.image_container
# 	name_container = properties.name_container # might be null
# 	if name_container:
# 		dialogue_box_properties["include_speaker_in_text"] = false
	
# func transfer_dialogue_box(new_box : MessageAppBox) -> void:
# 	if current_dialogue_box && current_dialogue_box == text_message_box: #disconnect signals
# 		text_message_box.back_button.mouse_entered.disconnect(mouse_exited) 
# 		text_message_box.back_button.mouse_exited.disconnect(mouse_entered)
# 	current_dialogue_box = new_box
# 	print("Transferring dialogue box : ", new_box, new_box.resource_file)
# 	dialogue_box_properties = new_box.resource_file
# 	#Transfer all properties over
# 	transferBoxProperties()

# func set_dialogue_box(new_resource : DialogueBoxResource) -> void:
# 	if in_dialogue: return
# 	var diag_box_inst : DialogueBoxProperties = new_resource.dialogue_box.instantiate()
# 	current_dialogue_box = diag_box_inst
# 	current_dialogue_box.visible = false
# 	dialogue_box_properties = new_resource
# 	canvas_layer.add_child(current_dialogue_box)
# 	await current_dialogue_box.ready
# 	#Transfer all properties over
# 	transferBoxProperties()

# func clear_children(container : Node) -> void:
# 	for n in container.get_children():
# 		container.remove_child(n)
# 		n.queue_free() 

# func add_new_line(current_dialogue_info : InkLineInfo, no_animation : bool = false) -> void:
# 	if current_dialogue_box is MainDialogueBox:
# 		var main_db : MainDialogueBox = current_dialogue_box
# 		main_db.add_line(current_dialogue_info)
# 		return
		
# 	var speaker : String = current_dialogue_info.speaker
	
# 	var newline : DialogueLine
# 	if speaker == "Olivia":
# 		newline = dialogue_box_properties.protagonist_dialogue_line.instantiate()
# 	else:
# 		newline = dialogue_box_properties.dialogue_line.instantiate()
# 		var new_message_sound : Node = new_message_sound_scene.instantiate()
# 		main.add_child(new_message_sound)

# 	newline.line_info = current_dialogue_info
# 	newline.text_properties = dialogue_box_properties
# 	newline.no_animation = no_animation
# 	var char_resource : CharacterResource = SaveSystem.get_character(speaker)
# 	if char_resource:
# 		newline.speaker_resource = char_resource
# 	else:
# 		print("No speaker ", speaker)
# 	if image_container:
# 		newline.image_container = image_container
# 	if name_container:
# 		newline.name_container = name_container
		
# 	current_line_label = newline
# 	current_line_label.initialize()
# 	dialogue_container.add_child(current_line_label)

# func display_current_dialogue() -> void:
# 	#clear any old dialogue
# 	if dialogue_box_properties["clear_box_after_each_dialogue"]:
# 		clear_children(dialogue_container)
# 	var current_dialogue_info : InkLineInfo = all_dialogues[0]
# 	current_conversation.push_back(current_dialogue_info)
# 	add_new_line(current_dialogue_info)

# func check_for_choices() -> void:
# 	if current_dialogue_index == all_dialogues.size()-1: #if at the end of the dialogue, check for choices or exit
# 		if are_choices:
# 			set_choices(current_choices)
	
# func skip_dialogue_animation() -> void:
# 	if current_dialogue_box is MainDialogueBox:
# 		var main_db : MainDialogueBox = current_dialogue_box
# 		main_db.skip()
# 	else:
# 		current_line_label.skip()

# func say(dialogues : Array[InkLineInfo]) -> void:
# 	in_dialogue = true
# 	current_dialogue_box.visible = true
# 	all_dialogues=dialogues
# 	current_dialogue_index = 0
# 	display_current_dialogue()

# func load_convo(target_name : String, json_name : String, phone_conversation : bool = false) -> void:
# 	#print("Loading convo: ", target_name, " | ", json_name)
# 	var json_file : JSON = load(INK_FILE_PATH+json_name)
# 	var target_resource : Resource #could be CharacterResource or ChatResource 
# 	if phone_conversation:
# 		target_resource = SaveSystem.get_phone_chat(target_name)
# 	else:
# 		target_resource = SaveSystem.get_character(target_name)
# 	#print("Target resource: ", target_resource)
# 	target_resource.load_chat(json_file)

# func match_command(text_ : String) -> void:
# 	#break up command into parameters
# 	var parameters_array : Array[String]
# 	var current_parameter : String = ""
# 	var within_quotations : bool = false
# 	for character in text_:
# 		if character == "\"":
# 			within_quotations = !within_quotations
# 			continue
# 		elif !within_quotations:
# 			if character == " ":
# 				parameters_array.push_back(current_parameter)
# 				current_parameter = ""
# 				continue
# 		current_parameter += character
# 	parameters_array.push_back(current_parameter)
# 	print("Parameters array: ", parameters_array)
# 	#match the first parameters (the command)
# 	match(parameters_array[0]):
# 		"/give_item":
# 			SaveSystem.add_item(parameters_array[1])
# 			'''
# 			set this automatically so writers don't have to keep
# 			writing /give_item and /has_item right after each other
# 			'''
# 			SaveSystem.set_key("has_item_flag", true) 
# 		"/remove_item":
# 			#alerts if you don't have enough items
# 			var result : int = SaveSystem.remove_item(parameters_array[1])
# 			if result == 0:
# 				SaveSystem.set_key("remove_item_flag", false)
# 			else:
# 				SaveSystem.set_key("remove_item_flag", true)
# 		"/has_item":
# 			var result : int = SaveSystem.item_count(parameters_array[1])
# 			var tf_result : bool = true
# 			if result == 0: #does not have item
# 				print("User does not have item: ", parameters_array[1])
# 				tf_result = false
# 			else:
# 				print("User has item: ", parameters_array[1])
# 			SaveSystem.set_key("has_item_flag", tf_result)
# 			if parameters_array.size() >= 3:
# 				#writers can set a custom variable to store the results in
# 				var custom_var : String = parameters_array[2]
# 				SaveSystem.set_key(custom_var, tf_result)
# 		"/give_task":
# 			SaveSystem.add_task(parameters_array[1])
# 		"/complete_task":
# 			SaveSystem.complete_task(parameters_array[1])
# 		"/load_chat":
# 			load_convo(parameters_array[1], parameters_array[2])
# 		"/load_phone_chat":
# 			load_convo(parameters_array[1], parameters_array[2], true)
# 		"/die_roll":
# 			var stat : String = parameters_array[1].to_lower()
# 			var difficulty : String = parameters_array[2].to_lower()
# 			var roll : int = rng.randi_range(1,20) #20-sided die
# 			var modified_roll : int = roll + (SaveSystem.get_key(stat)-10)
# 			var threshold : int = 0
# 			match(difficulty):
# 				"hard":
# 					threshold = 17
# 				"medium":
# 					threshold = 13
# 				"easy":
# 					threshold = 10
# 			print("Die roll!: ", modified_roll)
# 			if modified_roll >= threshold:
# 				SaveSystem.set_key("die_roll_flag", true)
# 			else:
# 				SaveSystem.set_key("die_roll_flag", false)
# 		"/change_location":
# 			var target_resource : CharacterResource = SaveSystem.get_character(parameters_array[1])
# 			var target_location : String = parameters_array[2]
# 			target_resource.change_location(target_location)
# 		"/fade_screen":
# 			if parameters_array[1] == "true":
# 				current_dialogue_box.visible = false
# 				GuiSystem.fade_loading_screen_in()
# 			elif parameters_array[1] == "false":
# 				var tween : Tween = await GuiSystem.fade_loading_screen_out()
# 				await tween.finished
# 				current_dialogue_box.visible = true
# 		"/toggle_ui":
# 			if parameters_array[1] == "true":
# 				current_dialogue_box.visible = true
# 			elif parameters_array[1] == "false":
# 				current_dialogue_box.visible = false
# 		"/wait":
# 			waiting = true
# 			var wait_time : float = float(parameters_array[1])
# 			await get_tree().create_timer(wait_time).timeout
# 			waiting = false
# 			done_waiting.emit()
# 		"/play_animation": ##WIP
# 			var character_name : String = parameters_array[1]
# 			var animation_name : String = parameters_array[2]
# 			print("Playing animation ", character_name, " for ", animation_name)
# 			var npc_model : NPC = ContentLoader.get_active_npc(character_name).npc
# 			if npc_model:
# 				npc_model.play_animation(animation_name)
			
# func advance_dialogue() -> void:
# 	if (
# 		!in_dialogue
# 		or !is_instance_valid(current_dialogue_box)
# 		or are_choices
# 		or waiting
# 	): return

# 	print("Advancing dialogue: ", !in_dialogue, !is_instance_valid(current_dialogue_box), are_choices, waiting)

# 	if (
# 		(
# 			current_line_label
# 			and current_line_label.done_state == true
# 		)
# 		or (
# 			current_dialogue_box is MainDialogueBox 
# 			and current_dialogue_box.done_state == true
# 		)
# 	):
# 		display_current_container()
		
# 	else:
# 		skip_dialogue_animation()

# 	if not GuiSystem.in_phone:
# 		var dialogue_advance_sound_instance: FmodEventEmitter3D = dialogue_advance_sound.instantiate()
# 		main.add_child(dialogue_advance_sound_instance)


# #CLICK TO ADVANCE DIALOGUE
# var pressed : bool = false


# func _process(_delta: float) -> void:
# 	if (Input.is_action_pressed("dialogic_default_action")):
# 		if !pressed:
# 			advance_dialogue()
# 			pressed = true
# 	else:
# 		pressed = false

# func change_container(redirect:String) -> void:
# 	are_choices = false
# 	if !current_dialogue_box is MainDialogueBox:
# 		if dialogue_box_properties["clear_box_after_each_dialogue"] == false:
# 			for choice in current_choice_labels:
# 				choice_container.remove_child(choice)
# 				choice.queue_free()
# 			current_choice_labels = []
# 	Ink.make_choice(redirect)
# 	display_current_container()

# func set_choices(choices:Array[InkChoiceInfo]) -> void:
# 	are_choices = true
# 	if current_dialogue_box is MainDialogueBox:
# 		var main_db : MainDialogueBox = current_dialogue_box
# 		main_db.set_choices(choices)
# 	else:
# 		for choice : InkChoiceInfo in choices:
# 			if choice.jump == "":
# 				#choice info text
# 				continue
# 			var newchoice : ChoiceButton = dialogue_box_properties.choice_button.instantiate()
# 			newchoice.choice_info = choice
# 			newchoice.text_properties = dialogue_box_properties
			
# 			newchoice.selected.connect(change_container)
# 			choice_container.add_child(newchoice)
# 			current_choice_labels.push_back(newchoice)

# ################################################################################################
# #JSON RELATED
# func convert_to_lines_array(array : Array) -> Array[InkLineInfo]:
# 	var new_array : Array[InkLineInfo] = []
# 	for item : InkLineInfo in array:
# 		new_array.push_back(item)
# 	return new_array

# func convert_to_choices_array(array : Array) -> Array[InkChoiceInfo]:
# 	var new_array : Array[InkChoiceInfo] = []
# 	for item : InkChoiceInfo in array:
# 		new_array.push_back(item)
# 	return new_array
	

# func display_current_container() -> void:
# 	if dialogue_box_properties["clear_box_after_each_dialogue"]:
# 		#check that it's loaded
# 		clear_children(choice_container)
# 	var content : Variant = Ink.get_content()
# 	'''
# 	Ink.get_content() returns Array[InkNode]
# 	InkNode can be InkLineInfo or InkChoiceInfo
# 	'''
# 	if content[0] is InkLineInfo:
# 		var line : InkLineInfo = content[0]
# 		if line.speaker == "System" and line.text == "end":
# 			on_content_end()
# 		elif line.text[0] == "/":
# 			await match_command(line.text)
# 			display_current_container()
# 		else:
# 			say([line])
# 	elif content[0] is InkChoiceInfo:
# 		var choices : Array[InkChoiceInfo] = []
# 		for choice : InkChoiceInfo in content:
# 			choices.push_back(choice)
# 		set_choices(choices)

# func on_content_end()-> void:
# 	in_dialogue = false
# 	current_line_label = null
# 	if current_dialogue_box == text_message_box: #if focused dialogue box is message app
# 		current_phone_resource.end_chat(current_conversation)
# 		current_phone_resource = null
# 	else:
# 		current_dialogue_box.visible = false
# 		current_dialogue_box.queue_free()
# 		if current_character_resource:
# 			current_character_resource.end_chat()
# 	current_conversation = []

# func get_first_message(json : JSON) -> InkLineInfo:
# 	return Ink.get_first_message(json)

# ## STARTING DIALOGUE
# func begin_dialogue(file : JSON) -> void:
# 	assert(file != null, "You forgot to assign a JSON file!")
# 	if in_dialogue:
# 		print("You can't start a new chat while in a dialogue!")
# 		return
# 	current_choice_labels = []
# 	Ink.from_JSON(file)
# 	display_current_container()

# func resume_dialogue(address : InkAddress) -> void:
# 	if in_dialogue:
# 		print("You can't start a new chat while in a dialogue!")
# 		return
# 	current_choice_labels = []
# 	Ink.from_address(address)
# 	display_current_container()
# ## END STARTING DIALOGUE

# #CHARACTER-RELATED
# func from_character(char_rsc : CharacterResource, file : JSON) -> void:
# 	current_character_resource = char_rsc
# 	begin_dialogue(file)

# #PHONE-RELATED
# func find_contact(chat_name:String) -> ChatResource:
# 	var phone_chat : ChatResource = SaveSystem.get_phone_chat(chat_name)
# 	return phone_chat #null or chat

# func to_phone(chat_name : String, file : JSON) -> void: # called to load json into phone
# 	var chat : ChatResource = find_contact(chat_name)
# 	current_phone_resource = chat
# 	current_phone_resource.load_chat(file)

# func start_text_convo(_text_message_box : MessageAppBox,chat_name : String) -> void: # called when player opens chat
# 	text_message_box = _text_message_box
# 	# opens the first loaded conversation or resumes the current one
# 	transfer_dialogue_box(text_message_box)
# 	mouse_contained_within_gui = true
# 	text_message_box.back_button.mouse_entered.connect(mouse_exited) 
# 	text_message_box.back_button.mouse_exited.connect(mouse_entered)
# 	var chat : ChatResource = find_contact(chat_name)
# 	current_phone_resource = chat
# 	current_phone_resource.start_chat() # either starts new one of resumes old one

# func pause_text_convo(hiding_phone : bool = false) -> void:
# 	if current_phone_resource == null or dialogue_container == null: return
# 	GuiSystem.hid_phone_mid_convo = hiding_phone
# 	current_phone_resource.pause_chat(current_conversation) # stores Inky hierarchy
# 	in_dialogue = false
# 	current_line_label = null
# 	dialogue_container.mouse_entered.disconnect(mouse_entered) 
# 	dialogue_container.mouse_exited.disconnect(mouse_exited)
	
# func load_past_messages(past_chats : Array[InkLineInfo]) -> void:
# 	#print("Loading past messages: ", past_chats)
# 	current_conversation = past_chats
# 	for n in range(current_conversation.size()):
# 		var chat : InkLineInfo = current_conversation[n]
# 		add_new_line(chat, true)

# #reset dialogue array
# func _on_visibility_changed(visible_state : bool) -> void:
# 	if visible_state:
# 		all_dialogues = []
