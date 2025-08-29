class_name MainDialogueBox extends DialogueBoxProperties

@export var protag_talking_setup : Control
@onready var protag_dialogue_backer : Control = protag_talking_setup.get_node("DialogueBacker")

@export var npc_talking_setup : Control
@onready var npc_dialogue_backer : Control = npc_talking_setup.get_node("DialogueBacker")

@export var choices_setup : Control

var current_speaker : CharacterResource
var previous_speaker : CharacterResource

var text_label : RichTextLabel
var speaker_image_label : TextureRect
var previous_speaker_image_label : TextureRect

@onready var choice_left : TextureRect = $Choices/AspectRatioContainer/Control/ChoiceLeft
@onready var choice_right : TextureRect = $Choices/AspectRatioContainer/Control/ChoiceRight
@onready var choice_up : TextureRect = $Choices/AspectRatioContainer/Control/ChoiceUp
@onready var choice_down : TextureRect = $Choices/AspectRatioContainer/Control/ChoiceDown
@onready var choice_info : RichTextLabel = $Choices/AspectRatioContainer/Control/ChoiceInfo

class LocalChoiceButton:
	var info : InkChoiceInfo
	var button : HoverButton
	func _init(_texture_rect : TextureRect, _info : InkChoiceInfo) -> void:
		_texture_rect.visible = true
		button = _texture_rect.get_node("RichTextLabel/Button")
		info = _info
		
		button.change_text(info.text)
		button.pressed.connect(on_pressed)
	func on_pressed() -> void:
		DialogueSystem.change_container(info.jump, info.text)

var local_choice_buttons : Array[LocalChoiceButton] = []


var UI_STATES : Dictionary[String, String] = {
	PROTAG_SPEAKER = "ProtagSpeaker",
	NPC_SPEAKER =  "NPCSpeaker",
	CHOICES = "Choices",
}

var current_ui_state : String = UI_STATES.PROTAG_SPEAKER

func assign_nodes(parent : Control):
	text_label = parent.get_node("DialogueBacker/ScrollContainer/RichTextLabel")
	speaker_image_label = parent.get_node("CharacterImage")
	previous_speaker_image_label = parent.get_node("LastCharacterImage")

func set_ui_state(ui_state : String):
	current_ui_state = ui_state
	local_choice_buttons = []
	if ui_state == UI_STATES.PROTAG_SPEAKER:
		protag_talking_setup.visible = true
		protag_dialogue_backer.visible = true
		
		npc_talking_setup.visible = false
		
		choices_setup.visible = false
		
		assign_nodes(protag_talking_setup)
	elif ui_state == UI_STATES.NPC_SPEAKER:
		protag_talking_setup.visible = false
		npc_talking_setup.visible = true
		
		npc_dialogue_backer.visible = true
		
		choices_setup.visible = false
		
		assign_nodes(npc_talking_setup)
	elif ui_state == UI_STATES.CHOICES:
		protag_talking_setup.visible = true
		npc_talking_setup.visible = false
		
		protag_dialogue_backer.visible = false
		npc_dialogue_backer.visible = false
		
		choices_setup.visible = true
		
func _ready() -> void:
	set_ui_state(UI_STATES.PROTAG_SPEAKER)
		
func add_line(line : InkLineInfo) -> void:
	current_speaker = SaveSystem.character_to_resource[line.speaker]
	if (
		current_speaker != previous_speaker
		 or current_ui_state == UI_STATES.CHOICES
	):
		if current_speaker.name == "Olivia":
			set_ui_state(UI_STATES.PROTAG_SPEAKER)
		else:
			set_ui_state(UI_STATES.NPC_SPEAKER)
		
		if current_speaker.image_polaroid_popout:
			speaker_image_label.texture = current_speaker.image_polaroid_popout
		else:
			speaker_image_label.texture = current_speaker.image_polaroid
		
		if previous_speaker:
			print("Set previous speaker image label")
			previous_speaker_image_label.texture = previous_speaker.image_polaroid
		
	previous_speaker = current_speaker
		
	text_label.text = "[color=black]"+line.text+"[/color]"

func set_choices(choices : Array[InkChoiceInfo]) -> void:
	print("Got choices: ", choices[0].text)
	set_ui_state(UI_STATES.CHOICES)
	var choice_rects : Array[TextureRect] = [choice_down, choice_up, choice_right, choice_left]
	for choice : InkChoiceInfo in choices:
		if choice.jump.size() == 0:
			#this is choice info text
			choice_info.text = choice.text
		else:
			var choice_button := LocalChoiceButton.new(choice_rects.pop_back(), choice)
			local_choice_buttons.push_back(choice_button)
	#hide any remaining choice rects
	for choice_rect : TextureRect in choice_rects:
		choice_rect.visible = false
