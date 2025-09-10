extends Control

@onready var rtl : RichTextLabel  = $RichTextLabel

func set_contact(character : CharacterResource) -> void:
	rtl.text = character.name