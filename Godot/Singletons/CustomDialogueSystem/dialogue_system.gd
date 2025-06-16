extends Node

@onready var canvas_layer : CanvasLayer =  get_tree().root.get_node("Node3D/CanvasLayer")

#DIALOGUE STYLES
var dialogue_boxes : Array
var dialogue_container : VBoxContainer
var choice_container : VBoxContainer
var image_container : TextureRect
var name_container : RichTextLabel
var special_font : FontFile

var text_properties : Dictionary

#CHARACTERS
var character_properties : Dictionary
var current_dialogue_box : Control

var current_choices : Array
var current_choice_labels : Array

const FILE_PATH = "res://Singletons/CustomDialogueSystem/dialogue_data.tres"
@onready var dialogue_data:Resource = load(FILE_PATH)

# DIALOGUE PROCESSING
var diag_line : PackedScene
var choice_button : PackedScene

#DIALOGUES (FULL CHARACTER SENTENCES)
var all_dialogues : Array = []
var current_dialogue_index = 0

#LINES (THE ACTUAL LINES ON THE TEXTBOX THAT GET UNCOVERED ONE BY ONE)
var current_line_label : Control

#FROM JSON
var json_file : Dictionary

var are_choices = false

#in case we want to switch dialogue box mid conversation


func load_properties():
	dialogue_boxes = dialogue_data["dialogue_boxes"]
	character_properties = dialogue_data["character_properties"]
	
func transferBoxProperties():
	diag_line = current_dialogue_box.dialogue_line
	choice_button = current_dialogue_box.choice_button
	dialogue_container = current_dialogue_box.dialogue_container
	choice_container = current_dialogue_box.choice_container
	image_container = current_dialogue_box.image_container
	name_container = current_dialogue_box.name_container # might be null
	text_properties = current_dialogue_box.text_properties
	special_font = current_dialogue_box.text_font
	if name_container:
		text_properties["name_in_separate_container"] = false
	if dialogue_container == choice_container:
		#Decides whether to prefix choices with "YOU:"
		text_properties["prefix_choices"] = true
	else:
		text_properties["prefix_choices"] = false
	
	current_dialogue_box.visible = false
	
func transferDialogueBox(new_box : Control):
	print("Transferring dialogue box: ", new_box)
	current_dialogue_box = new_box
	#Transfer all properties over
	transferBoxProperties()

func setDialogueBox(index : int):
	print("Setting dialogue box: ", index)
	#get all current dialogue/choices/images/names, if any
	
	if current_dialogue_box:
		current_dialogue_box.queue_free()
	
	var diag_box_inst = dialogue_boxes[index].instantiate()
	current_dialogue_box = diag_box_inst
	canvas_layer.add_child(current_dialogue_box)
	#Transfer all properties over
	transferBoxProperties()

func _ready() -> void:
	load_properties()

func clear_children(container):
	for n in container.get_children():
		container.remove_child(n)
		n.queue_free() 

func add_new_line(speaker : String, line_text :String):
	var newline = diag_line.instantiate()
	newline.line_text = line_text
	newline.line_speaker = speaker
	newline.text_color = text_properties["default_text_color"]
	newline.name_color = text_properties["default_name_color"]
	
	if special_font:
		print("special font detected: ", special_font)
		newline.special_font = special_font
		#dialogue_container.add_theme_font_override("normal_font", special_font)
	
	if character_properties.has(speaker): #if there is an entry for this character, get its properties
		var image_key = "full"
		if text_properties.has("image_key"):
			image_key = text_properties["image_key"]
		var image : CompressedTexture2D
		if character_properties[speaker]["image"].has(image_key):
			image = character_properties[speaker]["image"][image_key]
		else:
			image = character_properties[speaker]["image"]["full"]
		image_container.texture = image
		if character_properties[speaker].has("text_color"):
			newline.text_color = character_properties[speaker]["text_color"]
		if character_properties[speaker].has("name_color"):
			newline.name_color = character_properties[speaker]["name_color"]
	else:
		print("No speaker ", speaker)
	
	if name_container:
		newline.line_speaker = "" #we aren't putting the speaker in the text, we are putting it in the name container
		name_container.add_theme_font_size_override("normal_font_size", text_properties["name_size"])
		name_container.text = "[color="+newline.name_color+"]"+speaker.to_upper()+"[/color]"
	newline.text_properties = text_properties
	current_line_label = newline
	current_line_label.initialize()
	dialogue_container.add_child(current_line_label)

func display_current_dialogue():
	#clear any old dialogue
	if text_properties.has("clear_box_after_each_dialogue") and text_properties["clear_box_after_each_dialogue"]:
		clear_children(dialogue_container)
	var speaker = all_dialogues[current_dialogue_index]["speaker"]
	var line_text = all_dialogues[current_dialogue_index]["text"]
	add_new_line(speaker, line_text)
	current_line_label.done.connect(check_for_choices)

func check_for_choices():
	if current_dialogue_index == all_dialogues.size()-1: #if at the end of the dialogue, check for choices or exit
		if are_choices:
			set_choices(current_choices)
	
func skip_dialogue_animation():
	current_line_label.skip()

func say(dialogues : Array):
	current_dialogue_box.visible = true
	all_dialogues=dialogues
	current_dialogue_index = 0
	display_current_dialogue()
	
func advance_dialogue():
	if current_line_label.done_state == true:
		if current_dialogue_index < all_dialogues.size()-1: #within scope
			current_dialogue_index += 1
			display_current_dialogue()
		elif are_choices == false:
			#if you've finished all the dialogues, close the box
			current_dialogue_box.visible = false
	else:
		skip_dialogue_animation()
		
#CLICK TO ADVANCE DIALOGUE
func _input(event):
	if current_dialogue_box:
		if current_dialogue_box.visible == true:
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					advance_dialogue()

func change_container(redirect:String, choice_text:String):
	are_choices = false
	if text_properties.has("clear_box_after_each_dialogue") and text_properties["clear_box_after_each_dialogue"] == false:
		for choice in current_choice_labels:
			choice.queue_free()
		current_choice_labels = []
		add_new_line("YOU", choice_text)
	Ink.make_choice(redirect)
	display_current_container()

func set_choices(choices:Array):
	print("Choices: ", choices)
	are_choices = true
	for choice in choices:
		var newchoice = choice_button.instantiate()
		newchoice.choice_text = choice.text
		newchoice.redirect = choice.jump
		newchoice.text_properties = current_dialogue_box.text_properties
		newchoice.selected.connect(change_container)
		choice_container.add_child(newchoice)
		current_choice_labels.push_back(newchoice)

################################################################################################
#JSON RELATED
func display_current_container():
	if text_properties.has("clear_box_after_each_dialogue") and text_properties["clear_box_after_each_dialogue"]:
		#check that it's loaded
		clear_children(choice_container)
	#if json_file:
	var content = Ink.get_content()
	#print("Content = ", content)
	are_choices = false
	if content.choices.size() > 0:
		are_choices = true
		current_choices = content.choices
	if content.dialogue.size() > 0:
		say(content.dialogue)#json_file[current_container].text)
	else:
		current_dialogue_box.visible = false #if there's no extra dialogue (such as an option to end dialogue)

func from_JSON(file:String):
	Ink.from_JSON(file)
	display_current_container()

#reset dialogue array
func _on_visibility_changed(visible_state):
	if visible_state:
		all_dialogues = []
