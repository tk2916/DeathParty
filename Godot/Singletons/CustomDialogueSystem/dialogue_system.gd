extends Node

<<<<<<< Updated upstream
@onready var canvas_layer : CanvasLayer =  get_tree().root.get_node("Node3D/CanvasLayer")
=======
var canvas_layer : CanvasLayer
>>>>>>> Stashed changes

var in_dialogue : bool = false #other scripts check this
const FILE_PATH : String = "res://Singletons/CustomDialogueSystem/dialogue_data.tres"
var dialogue_data : Resource

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

<<<<<<< Updated upstream
=======
signal loaded_new_contact

func _init() -> void: #loading files
	dialogue_data = load(FILE_PATH)
	load_properties()

func _ready() -> void: #loading a node in the tree
	canvas_layer = get_tree().root.get_node("Main/CanvasLayer")
	
>>>>>>> Stashed changes
func load_directory(address : String):
	var dir : DirAccess = DirAccess.open(address)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	if dir:
		while file_name != "":
			if !dir.current_is_dir():
<<<<<<< Updated upstream
				print("Found file: " + file_name)
=======
>>>>>>> Stashed changes
				var file = load(address + file_name)
				if address == char_directory_address:
					dialogue_data.character_dictionary[file.name] = file
				elif address == messages_directory_address:
					phone_messages[file.name] = file
					loaded_new_contact.emit(file)
					
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the directory " + address)

func load_properties():
	#loading character & dialogue box directories
	load_directory(char_directory_address)
<<<<<<< Updated upstream
	print("Character dictionary: ", dialogue_data.character_dictionary)
=======
>>>>>>> Stashed changes
	character_properties = dialogue_data["character_dictionary"]
	load_directory(messages_directory_address)

#in case we want to switch dialogue box mid conversation
func transferBoxProperties():
	dialogue_container = current_dialogue_box.dialogue_container
	choice_container = current_dialogue_box.choice_container
	image_container = current_dialogue_box.image_container
	name_container = current_dialogue_box.name_container # might be null
	if name_container:
		dialogue_box_properties["include_speaker_in_text"] = false
	
func transferDialogueBox(new_box : Control):
<<<<<<< Updated upstream
	print("Transferring dialogue box: ", new_box.resource_file)
	current_dialogue_box = new_box
	#print("All dialogue boxes: ", dialogue_boxes)
	dialogue_box_properties = new_box.resource_file
	print("Box ID is: ", dialogue_box_id)
=======
	current_dialogue_box = new_box
	dialogue_box_properties = new_box.resource_file
>>>>>>> Stashed changes
	#Transfer all properties over
	transferBoxProperties()

func setDialogueBox(new_resource : Resource):
<<<<<<< Updated upstream
	#print("Setting dialogue box: ", index)
	#dialogue_box_id = index
=======
>>>>>>> Stashed changes
	if current_dialogue_box:
		current_dialogue_box.queue_free()
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

func add_new_line(speaker : String, line_text :String):
	var newline : Control
	if speaker == "Olivia":
		newline = dialogue_box_properties.protagonist_dialogue_line.instantiate()
	else:
		newline = dialogue_box_properties.dialogue_line.instantiate()
	newline.line_text = line_text
	newline.line_speaker = speaker
	newline.text_color = dialogue_box_properties["default_text_color"]
	newline.name_color = dialogue_box_properties["default_name_color"]
	
	if dialogue_box_properties.text_font:
<<<<<<< Updated upstream
		print("special font detected: ", dialogue_box_properties.text_font)
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
	if all_dialogues[current_dialogue_index].has("jump"):
		print("This line has jump: ", all_dialogues[current_dialogue_index])
		pass
		#Ink.make_choice(all_dialogues[current_dialogue_index]["jump"])
=======
>>>>>>> Stashed changes
	var line_text = all_dialogues[current_dialogue_index]["text"]
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
				SaveSystem.set_key("has_item_flag", false)
			else:
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
	if current_dialogue_box:
		if current_dialogue_box.visible == true:
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and are_choices == false:
					advance_dialogue()

func change_container(redirect:String, choice_text:String):
<<<<<<< Updated upstream
	print("Called change_containerr")
=======
>>>>>>> Stashed changes
	are_choices = false
	if dialogue_box_properties["clear_box_after_each_dialogue"] == false:
		for choice in current_choice_labels:
			choice.queue_free()
		current_choice_labels = []
	Ink.make_choice(redirect)
	display_current_container()

func set_choices(choices:Array):
<<<<<<< Updated upstream
	print("Choices: ", choices)
=======
>>>>>>> Stashed changes
	are_choices = true
	for choice in choices:
		var newchoice = dialogue_box_properties.choice_button.instantiate()
		newchoice.choice_text = choice.text
		newchoice.redirect = choice.jump
		newchoice.text_properties = dialogue_box_properties
		
		newchoice.selected.connect(change_container)
<<<<<<< Updated upstream
		print("sonnected change_container")
=======
>>>>>>> Stashed changes
		choice_container.add_child(newchoice)
		current_choice_labels.push_back(newchoice)

################################################################################################
#JSON RELATED
func display_current_container():
	if dialogue_box_properties["clear_box_after_each_dialogue"]:
		#check that it's loaded
		clear_children(choice_container)
<<<<<<< Updated upstream
	#if json_file:
=======
	#if content == null:
>>>>>>> Stashed changes
	var content = Ink.get_content()
	print("CONTENT GOT: ", content)
	if content is int:
		if content == 405: #end of story
			current_dialogue_box.visible = false
			in_dialogue = false
			return
	are_choices = false
	if content.size() == 1: #dialogue line
		if content[0].text[0] == "/":
			match_command(content[0].text)
			display_current_container()
		else:
			say(content)
<<<<<<< Updated upstream
	elif content.size() > 1: #choices
=======
	elif content.size() == 1 and content[0].has("jump"): #single choice (keep going to get more)
		var temp_choices_arr = content
		are_choices = true
		current_choices = temp_choices_arr
		set_choices(current_choices)
		
	elif content.size() > 1: #multiple choices
>>>>>>> Stashed changes
		are_choices = true
		current_choices = content
		set_choices(current_choices)

func from_JSON(file : JSON):
	assert(file != null, "You forgot to assign a JSON file!")
	Ink.from_JSON(file)
	display_current_container()
<<<<<<< Updated upstream
=======

#PHONE-RELATED
func find_contact(chat_name:String):
	if phone_messages.has(chat_name):
		return phone_messages[chat_name]

func to_phone(file : JSON, chat_name : String):
	var chat = find_contact(chat_name)
	chat.load_chat(file)

func start_text_convo(chat_name : String):
	var chat = find_contact(chat_name)
	chat.start_chat()
>>>>>>> Stashed changes

#reset dialogue array
func _on_visibility_changed(visible_state):
	if visible_state:
		all_dialogues = []
