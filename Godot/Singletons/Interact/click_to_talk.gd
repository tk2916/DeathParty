extends Node3D

@export var json_file : JSON

func _ready():
	$Outline.visible = false

func interact():
	DialogueSystem.from_JSON(json_file)
