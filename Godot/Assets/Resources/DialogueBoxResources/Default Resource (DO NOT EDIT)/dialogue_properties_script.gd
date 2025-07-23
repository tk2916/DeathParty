class_name DialogueBoxResource extends Resource

@export var dialogue_box : PackedScene
@export var dialogue_line : PackedScene = preload("res://Assets/GUIPrefabs/DialogueLinePrefabs/diag_line.tscn")
@export var choice_button : PackedScene = preload("res://Assets/GUIPrefabs/ChoicePrefabs/choice_button.tscn")
@export var protagonist_dialogue_line : PackedScene = preload("res://Assets/GUIPrefabs/DialogueLinePrefabs/diag_line.tscn")
@export var text_font : FontFile
@export var name_font : FontFile

@export var text_size : int = 15
@export var name_size : int = 15
@export var choice_size : int = 15
@export var default_text_color : String = "white"
@export var default_name_color : String = "yellow"
@export var default_choice_color : String = "yellow"
@export var line_separation : int = 0

@export var include_speaker_in_text : bool = true
@export var prefix_choices_with_player_name : bool = true
@export var clear_box_after_each_dialogue : bool = true

@export var text_animation : String = "typewriter"
@export var image_key : String = "full"
