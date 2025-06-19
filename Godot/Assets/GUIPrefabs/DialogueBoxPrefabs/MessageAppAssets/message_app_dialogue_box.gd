extends "res://Assets/GUIPrefabs/DialogueBoxPrefabs/dialogue_box_properties.gd"

@onready var tree = get_tree()
var tween : Tween

var left_anchor_before : float
var right_anchor_before : float

var left_anchor_after : float
var right_anchor_after : float

const duration : float = 3
@export var contact_name_label : RichTextLabel
@export var back_button : Button
@export var all_contacts : VBoxContainer

var contact_panel_scene : PackedScene = load("res://Assets/GUIPrefabs/DialogueBoxPrefabs/MessageAppAssets/contact_panel.tscn")

func _ready() -> void:
	left_anchor_before = anchor_left
	right_anchor_before = anchor_right
	left_anchor_after = left_anchor_before-1
	right_anchor_after = right_anchor_before-1
	
	back_button.pressed.connect(onBackPressed)
	DialogueSystem.loaded_new_contact.connect(instantiateContact)

func instantiateContact(contact : Resource):
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

func onContactPress(contact_name : String):
	contact_name_label.text = "[color=black]"+contact_name+"[/color]"
	DialogueSystem.start_text_convo(contact_name)
	tweenForward()
	
func onBackPressed():
	tweenBackward()
