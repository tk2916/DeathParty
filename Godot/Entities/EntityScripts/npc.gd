extends Node3D

var outline : Node3D

@export var character_resource : CharacterResource
@export var dialogue_box : DialogueBoxResource
@export var json_file : JSON

func _ready() -> void:
	print("Ready: ", name)
	$InteractionDetector.player_interacted.connect(on_interact)
	$InteractionDetector.player_in_range.connect(on_in_range)
	outline = get_node_or_null("Outline")
	if outline:
		outline.visible = false
		
	character_resource.unread.connect(on_unread)
	if json_file:
		character_resource.load_chat(json_file)

func on_unread():
	#$SpeechBubble.visible = true
	pass

func on_in_range(in_range : bool) -> void:
	if outline:
		outline.visible = in_range

func on_interact(_body : Node3D) -> void:
	print("Interacting")
	DialogueSystem.setDialogueBox(dialogue_box)
	character_resource.start_chat()
