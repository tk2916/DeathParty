class_name MessageAppBox extends DialogueBoxProperties

## CLASSES
const ParticipantPanel = preload("res://Assets/GUIPrefabs/PhonePrefabs/MessageAppAssets/participant_panel.gd")

## ANIMATION
var tween: Tween
var left_anchor_before: float
var right_anchor_before: float
var left_anchor_after: float
var right_anchor_after: float

const duration: float = .5
var contact_pressed := false

## NODES
@export var contact_name_label: RichTextLabel
@export var back_button: Button
@export var all_contacts: VBoxContainer
@export var participants_list: VBoxContainer
@export var dialogue_container: VBoxContainer
@export var choice_container: BoxContainer
@export var touch_screen: Control

## PREFABS/SCENES
@export var contact_panel_scene: PackedScene = preload("res://Assets/GUIPrefabs/PhonePrefabs/MessageAppAssets/contact_panel.tscn")
@export var participant_prefab: PackedScene = preload("res://Assets/GUIPrefabs/PhonePrefabs/MessageAppAssets/participant_panel.tscn")

@export var text_message_prefab_protag: PackedScene
@export var text_message_prefab_npc: PackedScene
@export var choice_prefab: PackedScene

var choices_array: Array[MessageAppChoiceButton] = []

class MessageAppChoiceButton:
	var info: InkChoiceInfo
	var button: PhoneChoiceButton
	var box: MessageAppBox
	func _init(_box: MessageAppBox, choice_container: Control, choice: InkChoiceInfo) -> void:
		info = choice
		box = _box
		button = box.choice_prefab.instantiate()
		button.set_text(choice.text)
		choice_container.add_child(button)
		button.button.pressed.connect(on_pressed)
		box.choices_array.push_back(self)

	func on_pressed() -> void:
		DialogueSystem.make_choice(info.jump)
		for item in box.choices_array:
			item.destroy()
		box.choices_array = []
	func destroy() -> void:
		print("Destroying button")
		button.destroy()

func _ready() -> void:
	left_anchor_before = anchor_left
	right_anchor_before = anchor_right
	left_anchor_after = left_anchor_before - 1
	right_anchor_after = right_anchor_before - 1

	participants_list.visible = false
	
	back_button.pressed.connect(on_back_pressed)
	DialogueSystem.loaded_new_contact.connect(instantiate_contact) # this signal is being emitted before the node is loaded
	DialogueSystem.emit_contacts()
#SETUP
func instantiate_contact(contact: ChatResource) -> void:
	#print("Instantiating with contact: ", contact.name)
	var new_contact: ContactPanel = contact_panel_scene.instantiate()
	new_contact.message_app = self
	new_contact.contact = contact
	all_contacts.add_child(new_contact)

#TWEENS
func tween_forward() -> Tween:
	var new_tween: Tween = tree.create_tween()
	new_tween.tween_property(self, "anchor_left", left_anchor_after, duration)
	new_tween.parallel().tween_property(self, "anchor_right", right_anchor_after, duration)
	return new_tween

func tween_backward() -> Tween:
	var new_tween: Tween = tree.create_tween()
	new_tween.tween_property(self, "anchor_left", left_anchor_before, duration)
	new_tween.parallel().tween_property(self, "anchor_right", right_anchor_before, duration)
	return new_tween
#END TWEENS

#SHOW MESSAGES
func on_contact_press(contact: ChatResource) -> void:
	print("Contact pressed! :", contact.name)
	if contact_pressed: return # prevent multiple presses
	contact_pressed = true
	
	setup_dms(contact)
	tween_forward()
	contact_pressed = false

func setup_dms(contact: ChatResource) -> void:
	set_participants(contact)
	clear_boxes()

	contact_name_label.text = "[color=black]" + contact.name + "[/color]"
	contact.start_chat()

func clear_boxes() -> void:
	#clear boxes
	for node: Node in dialogue_container.get_children():
		node.queue_free()
	for node: Node in choice_container.get_children():
		node.queue_free()

func set_participants(contact: ChatResource) -> void:
	#clear box
	for node: Node in participants_list.get_children():
		participants_list.remove_child(node)
		node.queue_free()
	var participants: Array[CharacterResource] = contact.participants
	for participant: CharacterResource in participants:
		var clone: ParticipantPanel = participant_prefab.instantiate()
		clone.set_contact(participant)

#HIDE MESSAGES
func on_back_pressed() -> void:
	#if !DialogueSystem.are_choices: #only allows you to leave if you aren't at a choice point
	tween_backward()
	pause_conversation()

## INHERITED
var last_speaker: String = ""
func add_line(line: InkLineInfo) -> void:
	touch_screen.visible = true
	var clone: DialogueLine
	#decide which prefab to instance
	if line.speaker == "Olivia":
		clone = text_message_prefab_protag.instantiate()
		Sounds.play_phone_typing()
	else:
		clone = text_message_prefab_npc.instantiate()
	
	#find speaker
	var character: CharacterResource = SaveSystem.get_character(line.speaker)
	assert(character != null, "Character " + line.speaker + " does not exist!")
	
	# show/hide image
	if last_speaker == line.speaker:
		clone.toggle_image(false)
	else:
		clone.set_image(character.image_profile)
	last_speaker = line.speaker

	#add to tree
	dialogue_container.add_child(clone)

	#animate text (fires the "done" signal so the dialogue can advance)
	var animated_label: AnimatedTextLabel = AnimatedTextLabel.new(self, clone.Text)
	print("Setting text: ", line.text, " in ", clone.Text)
	animated_label.set_text(line)

func set_choices(choices: Array[InkChoiceInfo]) -> void:
	touch_screen.visible = false
	for choice in choices:
		MessageAppChoiceButton.new(self, choice_container, choice)

func pause_conversation() -> void:
	if !DialogueSystem.are_choices:
		DialogueSystem.pause_dialogue()
		clear_boxes()

func skip() -> void:
	pass

# SHOW PARTICIPANTS
func _on_contact_name_mouse_entered() -> void:
	pass
	#participants_list.visible = true

func _on_contact_name_mouse_exited() -> void:
	participants_list.visible = false
