extends Control

@export var rtl : RichTextLabel

func set_contact(character : CharacterResource) -> void:
	print("Setting contact: ", character, " ", character.name)
	rtl.text = character.name