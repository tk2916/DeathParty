#extends "res://Assets/GUIDesignScripts/default_gui_button.gd"
extends Control

@export var character_profile : Control
@export var char_resource : Resource

func _ready() -> void:
	$"../Name".text = "[color=black]"+char_resource.name+"[/color]"

func _pressed() -> void:
	character_profile.visible = true
	character_profile.load_character(char_resource)
