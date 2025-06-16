extends Control
@export var dialogue_container : VBoxContainer
@export var choice_container : VBoxContainer
@export var image_container : TextureRect
@export var name_container : RichTextLabel
@export var dialogue_line = preload("res://Singletons/CustomDialogueSystem/DialogueLinePrefabs/diag_line.tscn")
@export var choice_button = preload("res://Singletons/CustomDialogueSystem/ChoicePrefabs/choice_button.tscn")
@export var text_font : FontFile

@export var text_properties : Dictionary = {
	"text_size" : 20,
	"default_text_color" : "white",
	"name_size" : 20,
	"default_name_color" : "yellow",
	"include_speaker_in_text" : true,
	"default_choice_color" : "yellow",
	"choice_size" : 10,
	"clear_box_after_each_dialogue" : false,
	"text_animation" : "typewriter",
	"image_key" : "full"
}

func _ready() -> void:
	if name_container:
		name_container.bbcode_enabled = true
