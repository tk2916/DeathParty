class_name MessageAppBox extends DialogueBoxProperties

## CLASSES
const ParticipantPanel = preload("res://Assets/GUIPrefabs/PhonePrefabs/MessageAppAssets/participant_panel.gd")

## ANIMATION
var tween : Tween
var left_anchor_before : float
var right_anchor_before : float
var left_anchor_after : float
var right_anchor_after : float

const duration : float = .5
var contact_pressed := false

## NODES
@export var contact_name_label : RichTextLabel
@export var back_button : Button
@export var all_contacts : VBoxContainer
@export var participants_list : VBoxContainer
@export var dialogue_container : VBoxContainer
@export var choice_container : BoxContainer

## PREFABS/SCENES
@export var contact_panel_scene : PackedScene = preload("res://Assets/GUIPrefabs/PhonePrefabs/MessageAppAssets/contact_panel.tscn")
@export var participant_prefab : PackedScene = preload("res://Assets/GUIPrefabs/PhonePrefabs/MessageAppAssets/participant_panel.tscn")

@export var text_message_prefab_protag : PackedScene
@export var text_message_prefab_npc : PackedScene
@export var choice_prefab : PackedScene

func _ready() -> void:
	left_anchor_before = anchor_left
	right_anchor_before = anchor_right
	left_anchor_after = left_anchor_before-1
	right_anchor_after = right_anchor_before-1

	participants_list.visible = false
	
	back_button.pressed.connect(on_back_pressed)
	DialogueSystem.loaded_new_contact.connect(instantiate_contact) #this signal is being emitted before the node is loaded

#SETUP
func instantiate_contact(contact : ChatResource) -> void:
	#print("Instantiating with contact: ", contact.name)
	var new_contact : ContactPanel = contact_panel_scene.instantiate()
	new_contact.message_app = self
	new_contact.contact = contact
	all_contacts.add_child(new_contact)

#TWEENS
func tween_forward() -> Tween:
	var new_tween : Tween = tree.create_tween()
	new_tween.tween_property(self, "anchor_left", left_anchor_after, duration)
	new_tween.parallel().tween_property(self, "anchor_right", right_anchor_after, duration)
	return new_tween

func tween_backward() -> Tween:
	var new_tween : Tween = tree.create_tween()
	new_tween.tween_property(self, "anchor_left", left_anchor_before, duration)
	new_tween.parallel().tween_property(self, "anchor_right", right_anchor_before, duration)
	return new_tween
#END TWEENS

#SHOW MESSAGES
func on_contact_press(contact : ChatResource) -> void:
	print("Contact pressed! :", contact.name)
	if contact_pressed: return # prevent multiple presses
	contact_pressed = true
	
	contact_name_label.text = "[color=black]"+contact.name+"[/color]"
	contact.start_chat()
	tween_forward()
	contact_pressed = false

func set_participants(contact : ChatResource) -> void:
	#clear box
	for node : Node in participants_list.get_children():
		participants_list.remove_child(node)
		node.queue_free()
	var participants : Array[CharacterResource] = contact.participants
	for participant : CharacterResource in participants:
		var clone : ParticipantPanel = participant_prefab.instantiate()
		clone.set_contact(participant)

#HIDE MESSAGES
func on_back_pressed() -> void:
	#if !DialogueSystem.are_choices: #only allows you to leave if you aren't at a choice point
	tween_backward()
	pause_conversation()

## INHERITED
func add_line(line : InkLineInfo) -> void:
	var clone : DialogueLine
	if line.speaker == "Olivia":
		clone = text_message_prefab_protag.instantiate()
	else:
		clone = text_message_prefab_npc.instantiate()
	dialogue_container.add_child(clone)
	AnimatedTextLabel.new(self, clone.Text)

func set_choices(choices : Array[InkChoiceInfo]) -> void:
	for choice in choices:
		var clone : ChoiceButton = choice_prefab.instantiate()
		choice_container.add_child(clone)

func pause_conversation() -> void:
	if !DialogueSystem.are_choices:
		DialogueSystem.pause_dialogue()
		for n in dialogue_container.get_children(): #clear messages
			dialogue_container.remove_child(n)
			n.queue_free()

# SHOW PARTICIPANTS
func _on_contact_name_mouse_entered() -> void:
	participants_list.visible = true

func _on_contact_name_mouse_exited() -> void:
	participants_list.visible = false