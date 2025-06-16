extends Node3D

@export var dialogue_box : Resource
@export var json_file : JSON

func _ready():
	$Outline.visible = false

func interact():
	print("Interacting")
	DialogueSystem.setDialogueBox(dialogue_box)
	DialogueSystem.from_JSON(json_file)
