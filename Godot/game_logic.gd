extends Node

@export var json_file : JSON
@export var message_box : DialogueBoxProperties
	
func _ready() -> void:
	print("Message box: ", message_box, " ", message_box.resource_file)
	DialogueSystem.transferDialogueBox(message_box)
	DialogueSystem.from_JSON(json_file)
