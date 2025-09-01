class_name NPC extends Interactable

var outline : Node3D

@export var character_resource : CharacterResource
@export var dialogue_box : DialogueBoxResource = preload("res://Assets/Resources/DialogueBoxResources/main_dialogue_box_properties.tres")
@export var starter_json : JSON = null#= preload("res://Assets/InkExamples/sample_dialogue_template.json")
@export var default_json: JSON = preload("res://Assets/InkExamples/sample_dialogue_template.json")

func _ready() -> void:
	super()
	#print("Ready: ", name)
	if character_resource:
		character_resource.unread.connect(on_unread)

func on_unread(unread : bool):
	#$SpeechBubble.visible = true
	pass

##INHERITED
func on_in_range(in_range : bool) -> void:
	##only show the outline if NPC has something to say
	var show_outline : bool = false
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
	elif starter_json:
		DialogueSystem.from_JSON(starter_json)
		starter_json = null
	elif default_json:
		DialogueSystem.from_JSON(default_json)
