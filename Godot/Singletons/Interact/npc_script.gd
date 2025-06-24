extends Node3D

@export var dialogue_box : Resource
@export var json_file : JSON
@export var character_resource : Resource

func on_unread():
	#$SpeechBubble.visible = true
	pass

func _ready():
	$Outline.visible = false
	character_resource.unread.connect(on_unread)
	DialogueSystem.to_character(character_resource, json_file)
	#character_resource.load_chat(json_file)

func interact():
	print("Interacting")
	DialogueSystem.setDialogueBox(dialogue_box)
	character_resource.start_chat()
	#DialogueSystem.from_JSON(json_file)
