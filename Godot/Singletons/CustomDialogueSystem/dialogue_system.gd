extends Node

var main : Node
var canvas_layer : CanvasLayer
var text_message_box : DialogueBoxNode

func _ready() -> void:
	main = get_tree().root.get_node_or_null("Main")
	if main:
		canvas_layer = main.get_node("CanvasLayer")
		text_message_box = canvas_layer.get_node("Phone/Screen/Background/MessageApp")
		print("Found text message box: ", text_message_box)

const INK_FILE_PATH : String = "res://Assets/InkExamples/"
var in_dialogue : bool = false #other scripts check this

var mouse_contained_within_gui : bool = true

#DIALOGUE BOX PROPERTIES
var dialogue_container : BoxContainer
var choice_container : BoxContainer
var image_container : TextureRect
var name_container : RichTextLabel

var dialogue_box_properties : DialogueBoxResource
var dialogue_box_id : int
var current_dialogue_box : Control

#DIALOGUES (FULL CHARACTER SENTENCES)
var all_dialogues : Array[InkLineInfo] = []
var current_dialogue_index : int = 0

#LINES
var current_line_label : DialogueLine

#CHOICES
var are_choices : bool = false
var current_choices : Array
var current_choice_labels : Array[Node]

#RESOURCE DIRECTORIES
const INK_INTERPRET_RSC_FILEPATH : String = "res://Singletons/InkInterpreter/ink_interpret_resource_blank.tres"
var blank_ink_interpret_resource : Resource = load(INK_INTERPRET_RSC_FILEPATH).duplicate(true)

var current_character_resource : CharacterResource = null

#PHONE CONVERSATIONS CAN BE PAUSED AND RETURNED TO
var current_phone_resource : ChatResource = null
var current_conversation : Array[InkLineInfo]

#RANDOM NUMBERS (for dice rolls)
var rng = RandomNumberGenerator.new()

#CONTACTS (phone)
signal loaded_new_contact

func emit_contacts():
	for key in SaveSystem.phone_chat_to_resource:
		loaded_new_contact.emit(SaveSystem.phone_chat_to_resource[key])

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
	
func transferDialogueBox(new_box : DialogueBoxNode):
	if current_dialogue_box && current_dialogue_box == text_message_box: #disconnect signals
		text_message_box.back_button.mouse_entered.disconnect(mouse_exited) 
		text_message_box.back_button.mouse_exited.disconnect(mouse_entered)
	current_dialogue_box = new_box
	print("Transferring dialogue box : ", new_box, new_box.resource_file)
	dialogue_box_properties = new_box.resource_file
	#Transfer all properties over
	transferBoxProperties()

func setDialogueBox(new_resource : DialogueBoxResource):
	if in_dialogue: return
	var diag_box_inst = new_resource.dialogue_box.instantiate()
	current_dialogue_box = diag_box_inst
	current_dialogue_box.visible = false
	dialogue_box_properties = new_resource
	canvas_layer.add_child(current_dialogue_box)
	await current_dialogue_box.ready
	#Transfer all properties over
	transferBoxProperties()

func clear_children(container):
	for n in container.get_children():
		container.remove_child(n)
		n.queue_free() 

func add_new_line(current_dialogue_info : InkLineInfo, no_animation : bool = false):
	if current_dialogue_box is MainDialogueBox:
		current_dialogue_box.add_line(current_dialogue_info)
		return
		
	var speaker = current_dialogue_info.speaker
	
	var newline : DialogueLine
	if speaker == "Olivia":
		newline = dialogue_box_properties.protagonist_dialogue_line.instantiate()
	else:
		newline = dialogue_box_properties.dialogue_line.instantiate()
	newline.line_info = current_dialogue_info
	newline.text_properties = dialogue_box_properties
	newline.no_animation = no_animation
	if SaveSystem.character_to_resource.has(speaker):
		newline.speaker_resource = SaveSystem.character_to_resource[speaker]
	else:
		print("No speaker ", speaker)
	if image_container:
		newline.image_container = image_container
	if name_container:
		newline.name_container = name_container
		
	current_line_label = newline
	current_line_label.initialize()
	dialogue_container.add_child(current_line_label)

func display_current_dialogue():
	#clear any old dialogue
	if dialogue_box_properties["clear_box_after_each_dialogue"]:
		clear_children(dialogue_container)
	var current_dialogue_info : InkLineInfo = all_dialogues[0]
	current_conversation.push_back(current_dialogue_info)
	add_new_line(current_dialogue_info)

func check_for_choices():
	if current_dialogue_index == all_dialogues.size()-1: #if at the end of the dialogue, check for choices or exit
		if are_choices:
			set_choices(current_choices)
	
func skip_dialogue_animation():
	if current_dialogue_box is MainDialogueBox:
		current_dialogue_box.skip()
	else:
		current_line_label.skip()

func say(dialogues : Array[InkLineInfo]):
	in_dialogue = true
	current_dialogue_box.visible = true
	all_dialogues=dialogues
	current_dialogue_index = 0
	display_current_dialogue()

func load_convo(target_name : String, json_name : String, phone_conversation : bool = false):
	print("Loading convo: ", target_name, " | ", json_name)
	var json_file : JSON = load(INK_FILE_PATH+json_name)
	var target_resource : Resource 
	if phone_conversation:
		target_resource = SaveSystem.phone_chat_to_resource[target_name]
	else:
		target_resource = SaveSystem.character_to_resource[target_name]
	#print("Target resource: ", target_resource)
	target_resource.load_chat(json_file)

func match_command(text_ : String):
	#break up command into parameters
	var parameters_array : Array[String]
	var current_parameter : String = ""
	var within_quotations : bool = false
	for char in text_:
		if char == "\"":
			within_quotations = !within_quotations
			continue
		elif !within_quotations:
			if char == " ":
				parameters_array.push_back(current_parameter)
				current_parameter = ""
				continue
		current_parameter += char
	parameters_array.push_back(current_parameter)
	print("Parameters array: ", parameters_array)
	#match the first parameters (the command)
	match(parameters_array[0]):
		"/give_item":
			SaveSystem.add_item(parameters_array[1])
			'''
			set this automatically so writers don't have to keep
			writing /give_item and /has_item right after each other
			'''
			SaveSystem.set_key("has_item_flag", true) 
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
			load_convo(parameters_array[1], parameters_array[2])
		"/load_phone_chat":
			load_convo(parameters_array[1], parameters_array[2], true)
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
			var target_resource : CharacterResource = SaveSystem.character_to_resource[parameters_array[1]]
			var target_location : String = parameters_array[2]
			target_resource.change_location(target_location)
		"/fade_screen":
			if parameters_array[1] == "true":
				ContentLoader.fade_loading_screen_in()
			elif parameters_array[1] == "false":
				ContentLoader.fade_loading_screen_out()
		"/toggle_ui":
			if parameters_array[1] == "true":
				current_dialogue_box.visible = false
			elif parameters_array[1] == "false":
				current_dialogue_box.visible = true
		"/wait":
			var wait_time : float = float(parameters_array[1])
			await get_tree().create_timer(wait_time).timeout
		"/play_animation": ##WIP
			var character_name : String = parameters_array[1]
			var animation_name : String = parameters_array[2]
			print("Playing animation ", character_name, " for ", animation_name)
			var character_resource : CharacterResource = SaveSystem.character_to_resource[character_name]
			
func advance_dialogue():
	if (
		(current_line_label
		and current_line_label.done_state == true)
		or (current_dialogue_box is MainDialogueBox 
		and current_dialogue_box.done_state == true)
	):
		display_current_container()
	else:
		skip_dialogue_animation()
		
#CLICK TO ADVANCE DIALOGUE
var pressed : bool = false
func _process(delta: float) -> void:
	if (current_dialogue_box && in_dialogue == true 
	&& are_choices == false && 
	#mouse_contained_within_gui && 
	Input.is_action_pressed("dialogic_default_action")):
		if !pressed:
			advance_dialogue()
			pressed = true
	else:
		pressed = false

func change_container(redirect:Array, choice_text:String):
	print("Changing container")
	are_choices = false
	if !current_dialogue_box is MainDialogueBox:
		if dialogue_box_properties["clear_box_after_each_dialogue"] == false:
			for choice in current_choice_labels:
				choice_container.remove_child(choice)
				choice.queue_free()
			current_choice_labels = []
	Ink.make_choice(redirect)
	display_current_container()

func set_choices(choices:Array[InkChoiceInfo]):
	are_choices = true
	if current_dialogue_box is MainDialogueBox:
		current_dialogue_box.set_choices(choices)
	else:
		for choice : InkChoiceInfo in choices:
			if choice.jump.size() == 0:
				#choice info text
				continue
			var newchoice : ChoiceButton = dialogue_box_properties.choice_button.instantiate()
			newchoice.choice_info = choice
			newchoice.text_properties = dialogue_box_properties
			
			newchoice.selected.connect(change_container)
			choice_container.add_child(newchoice)
			current_choice_labels.push_back(newchoice)

################################################################################################
#JSON RELATED
func convert_to_lines_array(array : Array) -> Array[InkLineInfo]:
	var new_array : Array[InkLineInfo] = []
	for item in array:
		new_array.push_back(item)
	return new_array

func convert_to_choices_array(array : Array) -> Array[InkChoiceInfo]:
	var new_array : Array[InkChoiceInfo] = []
	for item in array:
		new_array.push_back(item)
	return new_array
	

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
				if current_character_resource:
					current_character_resource.end_chat()
			in_dialogue = false
			current_conversation = []
			return
	are_choices = false
	if content[0] is InkLineInfo:#content.size() == 1 and !content[0].has("jump"): #dialogue line
		var lines : Array[InkLineInfo] = convert_to_lines_array(content)
		if content[0].text[0] == "/":
			match_command(content[0].text)
			display_current_container()
		else:
			say(lines)
	elif content[0] is InkChoiceInfo:#content.size() == 1 and content[0].has("jump"): #single choice (keep going to get more)
		var choices : Array[InkChoiceInfo] = convert_to_choices_array(content)
		are_choices = true
		set_choices(choices)
		
	elif content.size() > 1: #multiple choices
		are_choices = true
		current_choices = content
		set_choices(current_choices)

func get_first_message(json : JSON):
	return Ink.get_first_message(json)

func from_JSON(file : JSON, saved_ink_resource : InkResource = blank_ink_interpret_resource) -> void:#resume_from_hierarchy : Array = []): #non-phone dialoguebox
	assert(file != null, "You forgot to assign a JSON file!")
	if in_dialogue:
		print("You can't start a new chat while in a dialogue!")
		return
	print("Starting chat json: ", saved_ink_resource.output_stream)
	current_choice_labels = []
	Ink.from_JSON(file, saved_ink_resource)
	display_current_container()

#CHARACTER-RELATED
func from_character(char_rsc : CharacterResource, file : JSON) -> void:
	current_character_resource = char_rsc
	from_JSON(file)

#PHONE-RELATED
func find_contact(chat_name:String) -> ChatResource:
	if SaveSystem.phone_chat_to_resource.has(chat_name):
		return SaveSystem.phone_chat_to_resource[chat_name]
	return null

func to_phone(chat_name : String, file : JSON) -> void: # called to load json into phone
	var chat : ChatResource = find_contact(chat_name)
	current_phone_resource = chat
	current_phone_resource.load_chat(file)

func start_text_convo(_text_message_box : DialogueBoxNode,chat_name : String): # called when player opens chat
	text_message_box = _text_message_box
	# opens the first loaded conversation or resumes the current one
	print("Text message box: ", text_message_box)
	transferDialogueBox(text_message_box)
	mouse_contained_within_gui = true
	text_message_box.back_button.mouse_entered.connect(mouse_exited) 
	text_message_box.back_button.mouse_exited.connect(mouse_entered)
	var chat : ChatResource = find_contact(chat_name)
	current_phone_resource = chat
	current_phone_resource.start_chat() # either starts new one of resumes old one

func pause_text_convo() -> void:
	current_phone_resource.pause_chat(current_conversation) # stores Inky hierarchy
	in_dialogue = false
	dialogue_container.mouse_entered.disconnect(mouse_entered) 
	dialogue_container.mouse_exited.disconnect(mouse_exited)
	
func load_past_messages(past_chats : Array[InkLineInfo]) -> void:
	#print("Loading past messages: ", past_chats)
	current_conversation = past_chats
	for n in range(current_conversation.size()):
		var chat : InkLineInfo = current_conversation[n]
		add_new_line(chat, true)

#reset dialogue array
func _on_visibility_changed(visible_state : bool) -> void:
	if visible_state:
		all_dialogues = []
