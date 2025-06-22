extends Node

@onready var main = get_tree().root.get_node("Main")
@onready var canvas_layer : CanvasLayer = main.get_node("CanvasLayer")
@onready var text_message_box : MarginContainer = canvas_layer.get_node("Phone/Screen/Background/MessageApp")

var in_dialogue : bool = false #other scripts check this
const FILE_PATH : String = "res://Singletons/CustomDialogueSystem/dialogue_data.tres"
var dialogue_data : Resource

var mouse_contained_within_gui : bool = true

#DIALOGUE BOX PROPERTIES
var dialogue_container : VBoxContainer
var choice_container : VBoxContainer
var image_container : TextureRect
var name_container : RichTextLabel

var dialogue_box_properties : Resource
var dialogue_box_id : int

#CHARACTERS
var character_properties : Dictionary[String, Resource]
var current_dialogue_box : Control

#DIALOGUES (FULL CHARACTER SENTENCES)
var all_dialogues : Array = []
var current_dialogue_index : int = 0

#LINES
var current_line_label : Control

#CHOICES
var are_choices : bool = false
var current_choices : Array
var current_choice_labels : Array[Node]

#RESOURCE DIRECTORIES
var char_directory_address : String = "res://Assets/Resources/CharacterResources/"
var messages_directory_address : String = "res://Assets/GUIPrefabs/DialogueBoxPrefabs/MessageAppAssets/ChatResources/"
var phone_messages : Dictionary[String, Resource]
var blank_ink_interpret_resource : Resource = load("res://Singletons/InkInterpreter/ink_interpret_resource_blank.tres").duplicate(true)

#PHONE CONVERSATIONS CAN BE PAUSED AND RETURNED TO
var current_phone_resource : Resource = null
var current_conversation : Array[Dictionary]

signal loaded_new_contact

func _init() -> void: #loading files
	dialogue_data = load(FILE_PATH)
	load_properties()

func emit_contacts():
	for key in phone_messages:
		loaded_new_contact.emit(phone_messages[key])

func load_directory(address : String):
	if address == char_directory_address:
		SaveSystem.load_directory_into_dictionary(address, dialogue_data.character_dictionary)
	elif address == messages_directory_address:
		SaveSystem.load_directory_into_dictionary(address, phone_messages)

func load_properties():
	#loading character & dialogue box directories
	load_directory(char_directory_address)
	character_properties = dialogue_data["character_dictionary"]
	load_directory(messages_directory_address)

#in case we want to switch dialogue box mid conversation
func mouse_entered():
	mouse_contained_within_gui = true
func mouse_exited():
	mouse_contained_within_gui = false

func transferBoxProperties():
	mouse_contained_within_gui = true
	dialogue_container = current_dialogue_box.dialogue_container
	choice_container = current_dialogue_box.choice_container
	image_container = current_dialogue_box.image_container
	name_container = current_dialogue_box.name_container # might be null
	if name_container:
		dialogue_box_properties["include_speaker_in_text"] = false
	
func transferDialogueBox(new_box : Control):
	if current_dialogue_box && current_dialogue_box == text_message_box: #disconnect signals
		text_message_box.back_button.mouse_entered.disconnect(mouse_exited) 
		text_message_box.back_button.mouse_exited.disconnect(mouse_entered)
	current_dialogue_box = new_box
	dialogue_box_properties = new_box.resource_file
	#Transfer all properties over
	transferBoxProperties()

func setDialogueBox(new_resource : Resource):
	var diag_box_inst = new_resource.dialogue_box.instantiate()
	current_dialogue_box = diag_box_inst
	dialogue_box_properties = new_resource
	canvas_layer.add_child(current_dialogue_box)
	current_dialogue_box.visible = false
	#Transfer all properties over
	transferBoxProperties()

func clear_children(container):
	for n in container.get_children():
		container.remove_child(n)
		n.queue_free() 

func add_new_line(speaker : String, line_text : String, no_animation : bool = false):
	var newline : Control
	if speaker == "Olivia":
		newline = dialogue_box_properties.protagonist_dialogue_line.instantiate()
	else:
		newline = dialogue_box_properties.dialogue_line.instantiate()
	newline.line_text = line_text
	newline.line_speaker = speaker
	newline.text_color = dialogue_box_properties["default_text_color"]
	newline.name_color = dialogue_box_properties["default_name_color"]
	
	newline.no_animation = no_animation
	
	if dialogue_box_properties.text_font:
		newline.special_font = dialogue_box_properties.text_font
	
	if character_properties.has(speaker): #if there is an entry for this character, get its properties
		if image_container:
			var image_key : String = "image_" + dialogue_box_properties["image_key"]
			var image : CompressedTexture2D = character_properties[speaker][image_key]
			if image == null:
				#default to "full" if full is not null
				image = character_properties[speaker]["image_full"]
			if image != null:
				image_container.texture = image
		if character_properties[speaker]["text_color"] != "":
			newline.text_color = character_properties[speaker]["text_color"]
		if character_properties[speaker]["name_color"] != "":
			newline.name_color = character_properties[speaker]["name_color"]
	else:
		print("No speaker ", speaker)
	
	if name_container:
		newline.line_speaker = "" #we aren't putting the speaker in the text, we are putting it in the name container
		name_container.add_theme_font_size_override("normal_font_size", dialogue_box_properties["name_size"])
		name_container.text = "[color="+newline.name_color+"]"+speaker.to_upper()+"[/color]"
	newline.text_properties = dialogue_box_properties
	current_line_label = newline
	current_line_label.initialize()
	dialogue_container.add_child(current_line_label)

func display_current_dialogue():
	#clear any old dialogue
	if dialogue_box_properties["clear_box_after_each_dialogue"]:
		clear_children(dialogue_container)
	var speaker : String = ""
	if all_dialogues[current_dialogue_index].has("speaker"):
		speaker = all_dialogues[current_dialogue_index]["speaker"]
	var line_text = all_dialogues[current_dialogue_index]["text"]
	current_conversation.push_back({"speaker": speaker, "text": line_text})
	add_new_line(speaker, line_text)

func check_for_choices():
	if current_dialogue_index == all_dialogues.size()-1: #if at the end of the dialogue, check for choices or exit
		if are_choices:
			set_choices(current_choices)
	
func skip_dialogue_animation():
	current_line_label.skip()

func say(dialogues : Array):
	in_dialogue = true
	current_dialogue_box.visible = true
	all_dialogues=dialogues
	current_dialogue_index = 0
	display_current_dialogue()

func match_command(text_ : String):
	var parameters_array : PackedStringArray = text_.split(" ")
	match(parameters_array[0]):
		"/give_item":
			SaveSystem.add_item(parameters_array[1])
		"/remove_item":
			#alerts if you don't have enough items
			var result : int = SaveSystem.remove_item(parameters_array[1])
			if result == 0:
				SaveSystem.set_key("remove_item_flag", false)
			else:
				SaveSystem.set_key("remove_item_flag", true)
		"/has_item":
			var result : int = SaveSystem.item_count(parameters_array[1])
			if result == 0: #does not have item
				print("User does not have item: ", parameters_array[1])
				SaveSystem.set_key("has_item_flag", false)
			else:
				print("User has item: ", parameters_array[1])
				SaveSystem.set_key("has_item_flag", true)
		"/change_image":
			image_container.image = character_properties[parameters_array[1]][parameters_array[2]]
	
func advance_dialogue():
	if current_line_label.done_state == true:
			display_current_container()
	else:
		skip_dialogue_animation()
		
#CLICK TO ADVANCE DIALOGUE
func _input(event):
	if current_dialogue_box && in_dialogue == true:
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and are_choices == false:
					#if Rect2(Vector2(0,0), size).has_point(event.position):
					if mouse_contained_within_gui:
						advance_dialogue()

func change_container(redirect:String, choice_text:String):
	are_choices = false
	if dialogue_box_properties["clear_box_after_each_dialogue"] == false:
		for choice in current_choice_labels:
			choice.queue_free()
		current_choice_labels = []
	Ink.make_choice(redirect)
	display_current_container()

func set_choices(choices:Array):
	are_choices = true
	for choice in choices:
		var newchoice = dialogue_box_properties.choice_button.instantiate()
		newchoice.choice_text = choice.text
		newchoice.redirect = choice.jump
		newchoice.text_properties = dialogue_box_properties
		
		newchoice.selected.connect(change_container)
		choice_container.add_child(newchoice)
		current_choice_labels.push_back(newchoice)

################################################################################################
#JSON RELATED
func display_current_container():
	if dialogue_box_properties["clear_box_after_each_dialogue"]:
		#check that it's loaded
		clear_children(choice_container)
	var content = Ink.get_content()
	print("CONTENT GOT: ", content)
	if content is int:
		if content == 405: #end of story
			if current_dialogue_box == text_message_box: #if focused dialogue box is message app
				current_phone_resource.end_chat(current_conversation)
			else:
				current_dialogue_box.visible = false
				current_dialogue_box.queue_free()
			in_dialogue = false
			current_conversation = []
			return
	are_choices = false
	if content.size() == 1 and !content[0].has("jump"): #dialogue line
		if content[0].text[0] == "/":
			match_command(content[0].text)
			display_current_container()
		else:
			say(content)
	elif content.size() == 1 and content[0].has("jump"): #single choice (keep going to get more)
		are_choices = true
		set_choices(content)
		
	elif content.size() > 1: #multiple choices
		are_choices = true
		current_choices = content
		set_choices(current_choices)

func get_first_message(json : JSON):
	return Ink.get_first_message(json)


func from_JSON(file : JSON, saved_ink_resource : Resource = blank_ink_interpret_resource):#resume_from_hierarchy : Array = []): #non-phone dialoguebox
	assert(file != null, "You forgot to assign a JSON file!")
	print("Starting chat json: ", saved_ink_resource.output_stream)
	Ink.from_JSON(file, saved_ink_resource)
	display_current_container()
	
#PHONE-RELATED
func find_contact(chat_name:String):
	if phone_messages.has(chat_name):
		return phone_messages[chat_name]

func to_phone(file : JSON, chat_name : String): # called to load json into phone
	var chat = find_contact(chat_name)
	current_phone_resource = chat
	current_phone_resource.load_chat(file)

func start_text_convo(chat_name : String): # called when player opens chat
	# opens the first loaded conversation or resumes the current one
	transferDialogueBox(text_message_box)
	mouse_contained_within_gui = true
	text_message_box.back_button.mouse_entered.connect(mouse_exited) 
	text_message_box.back_button.mouse_exited.connect(mouse_entered)
	var chat = find_contact(chat_name)
	current_phone_resource = chat
	current_phone_resource.start_chat() # either starts new one of resumes old one

func pause_text_convo():
	current_phone_resource.pause_chat(current_conversation) # stores Inky hierarchy
	in_dialogue = false
	dialogue_container.mouse_entered.disconnect(mouse_entered) 
	dialogue_container.mouse_exited.disconnect(mouse_exited)
	
func load_past_messages(past_chats : Array[Dictionary]):
	#print("Loading past messages: ", past_chats)
	current_conversation = past_chats
	for n in range(current_conversation.size()):
		var chat = current_conversation[n]
		add_new_line(chat.speaker, chat.text, true)

#reset dialogue array
func _on_visibility_changed(visible_state):
	if visible_state:
		all_dialogues = []
