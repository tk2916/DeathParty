class_name NPC extends Interactable

var outline : Node3D

@export var character_resource : CharacterResource
@export var dialogue_box : DialogueBoxResource = preload("res://Assets/Resources/DialogueBoxResources/dialogue_box_properties_2.tres")
@export var json_file : JSON

func _ready() -> void:
	super()
	print("Ready: ", name)
	if character_resource:
		character_resource.unread.connect(on_unread)
		if json_file:
			character_resource.load_chat(json_file)

func on_unread(unread : bool):
	#$SpeechBubble.visible = true
	pass

##INHERITED
func on_in_range(in_range : bool) -> void:
	##only show the outline if NPC has something to say
	var show_outline : bool = false
	if json_file:
		show_outline = true
	if character_resource:
		if character_resource.has_chats():
			show_outline = true
	
	if show_outline:
		super(in_range)

func on_interact() -> void:
	super()
	DialogueSystem.setDialogueBox(dialogue_box)
	if character_resource:
		character_resource.start_chat()
	elif json_file:
		DialogueSystem.from_JSON(json_file)
