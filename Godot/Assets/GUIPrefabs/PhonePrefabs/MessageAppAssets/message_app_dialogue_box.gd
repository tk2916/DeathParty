class_name DialogueBoxNode extends DialogueBoxProperties

@onready var tree = get_tree()
var tween : Tween

var left_anchor_before : float
var right_anchor_before : float

var left_anchor_after : float
var right_anchor_after : float

const duration : float = .5
@export var contact_name_label : RichTextLabel
@export var back_button : Button
@export var all_contacts : VBoxContainer

var contact_panel_scene : PackedScene = load("res://Assets/GUIPrefabs/PhonePrefabs/MessageAppAssets/contact_panel.tscn")

var contact_pressed = false

func _ready() -> void:
	left_anchor_before = anchor_left
	right_anchor_before = anchor_right
	left_anchor_after = left_anchor_before-1
	right_anchor_after = right_anchor_before-1
	
	back_button.pressed.connect(onBackPressed)
	DialogueSystem.loaded_new_contact.connect(instantiateContact) #this signal is being emitted before the node is loaded
	DialogueSystem.emit_contacts()

func instantiateContact(contact : Resource):
	print("Instantiating with contact: ", contact.name)
	var new_contact = contact_panel_scene.instantiate()
	new_contact.message_app = self
	new_contact.contact = contact
	all_contacts.add_child(new_contact)

func tweenForward():
	var tween : Tween = tree.create_tween()
	tween.tween_property(self, "anchor_left", left_anchor_after, duration)
	tween.parallel().tween_property(self, "anchor_right", right_anchor_after, duration)
	return tween

func tweenBackward():
	var tween : Tween = tree.create_tween()
	tween.tween_property(self, "anchor_left", left_anchor_before, duration)
	tween.parallel().tween_property(self, "anchor_right", right_anchor_before, duration)
	return tween

func on_contact_press(contact : Resource):
	print("Contact pressed! :", contact.name)
	if contact_pressed: return # prevent multiple presses
	contact_pressed = true
	contact_name_label.text = "[color=black]"+contact.name+"[/color]"
	DialogueSystem.start_text_convo(contact.name)
	tweenForward()
	contact_pressed = false
	
func onBackPressed():
	if !DialogueSystem.are_choices: #only allows you to leave if you aren't at a choice point
		DialogueSystem.pause_text_convo()
		tweenBackward()
		for n in dialogue_container.get_children(): #clear messages
			dialogue_container.remove_child(n)
			n.queue_free()
