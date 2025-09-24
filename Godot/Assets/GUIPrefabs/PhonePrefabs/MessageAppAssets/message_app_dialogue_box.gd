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
@export var dialogue_scroll_container : ScrollContainer
@export var dialogue_container: VBoxContainer
@export var choice_container: BoxContainer
@export var touch_screen: Control

## PREFABS/SCENES
@export var contact_panel_scene: PackedScene = preload("res://Assets/GUIPrefabs/PhonePrefabs/MessageAppAssets/contact_panel.tscn")
@export var participant_prefab: PackedScene = preload("res://Assets/GUIPrefabs/PhonePrefabs/MessageAppAssets/participant_panel.tscn")

@export var text_message_prefab_protag: PackedScene
@export var text_message_prefab_npc: PackedScene
@export var choice_prefab: PackedScene

var delayed_lines : Array[InkLineInfo] = []

var first_message : bool = true;

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
		DialogueSystem.make_choice(info)
		for item in box.choices_array:
			item.destroy()
		box.choices_array = []
	func destroy() -> void:
		print("Destroying button")
		if is_instance_valid(button):
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

	if DialogueSystem.in_dialogue and GuiSystem.in_phone:
		print("Pausing conversation")
		pause_conversation()
	
	setup_dms(contact)
	tween_forward()
	contact_pressed = false

func setup_dms(contact: ChatResource) -> void:
	set_participants(contact)
	clear_boxes()

	contact_name_label.text = "[color=black]" + contact.name + "[/color]"
	contact.start_chat()

func clear_boxes() -> void:
	first_message = true;
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
var previous_text_instance : DialogueLineExpand
func add_line(line: InkLineInfo, skip_delay : bool = false) -> void:
	#DELAY BEFORE SHOWING (except on first message)
	var delay_time : float = line.text.length()/30.0
	
	dialogue_scroll_container.offset_bottom = 0
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
		if line.speaker != "Olivia":
			delay_time+=1 ##Delay if NPC is replying
		else:
			delay_time = 0
		clone.set_image(character.image_profile)
	last_speaker = line.speaker

	##DELAY BEFORE SHOWING MESSAGE
	if first_message or skip_delay or !DialogueSystem.in_dialogue:
		first_message = false
	else:
		delayed_lines.push_back(line)
		await get_tree().create_timer(delay_time).timeout
		var newline : InkLineInfo = delayed_lines.pop_back()
		if newline == null or line != newline:
			#a different conversation has started
			return

	if previous_text_instance:
		previous_text_instance.minimum_y_size = 0
		previous_text_instance.resize()
	#add to tree
	dialogue_container.add_child(clone)

	#animate text (fires the "done" signal so the dialogue can advance)
	var animated_label: AnimatedTextLabel = AnimatedTextLabel.new(self, clone.Text)
	animated_label.set_text(line)

	##this is hacky code to get around a bug where the text messages appear unaligned
	var anchor_left_before : float = clone.anchor_left
	clone.anchor_left = -1
	clone.anchor_bottom = anchor_left_before
	##

	previous_text_instance = clone

	#ADVANCE DIALOGUE AUTOMATICALLY (PHONE ONLY)
	DialogueSystem.advance_dialogue()

func set_choices(choices: Array[InkChoiceInfo]) -> void:
	touch_screen.visible = false
	for choice in choices:
		MessageAppChoiceButton.new(self, choice_container, choice)
	
	dialogue_scroll_container.offset_bottom = -41*choices.size()-10
	await get_tree().process_frame
	var scrollbar : VScrollBar = dialogue_scroll_container.get_v_scroll_bar()
	var max_scroll_length : float = scrollbar.max_value
	dialogue_scroll_container.scroll_vertical = int(max_scroll_length)
	#allows player to enter menu navigation through ui_up or ui_down
	MenuFocusGrabber.assign_buttons(null, null, choices_array[0].button.button, choices_array[-1].button.button)

func pause_conversation() -> void:
	var revert_one_line : bool = false #if we stopped the conversation early, it should be one line behind when they come back
	if delayed_lines.size() > 0:
		print("delayed lines > 0")
		revert_one_line = true
		delayed_lines.clear()
	if !DialogueSystem.are_choices:
		DialogueSystem.pause_dialogue(revert_one_line)
		clear_boxes()

func skip() -> void:
	pass

# SHOW PARTICIPANTS
func _on_contact_name_mouse_entered() -> void:
	pass
	#participants_list.visible = true

func _on_contact_name_mouse_exited() -> void:
	participants_list.visible = false
