class_name DialogueBoxProperties extends Control

@export var dialogue_container : VBoxContainer
@export var choice_container : VBoxContainer
@export var image_container : TextureRect
@export var name_container : RichTextLabel

#@export var dialogue_box_properties : Resource

'''
#set the resource if you don't want the DiaogueSystem to instatiate
the box (such as transferring dialogue functionaility over to a pre-existing
box)
'''
@export var resource_file : Resource

func _ready() -> void:
	if name_container:
		name_container.bbcode_enabled = true
