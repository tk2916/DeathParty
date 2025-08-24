extends Control

@export var contact_button : Button
@export var name_label : RichTextLabel
@export var time_label : RichTextLabel
@export var message_label : RichTextLabel
@export var image_label : TextureRect
@export var unread_alert : Control

var message_app : DialogueBoxNode
var contact : Resource

func on_pressed():
	message_app.on_contact_press(contact)

func on_unread(active : bool):
	if active:
		unread_alert.activate()
	else:
		unread_alert.deactivate()
	message_label.text = "[color=black]"+contact.display_message+"[/color]"

func _ready() -> void:
	contact_button.pressed.connect(on_pressed)
	contact.unread.connect(on_unread)
	name_label.text = "[color=black]"+contact.name+"[/color]"
	message_label.text = "[color=black]"+contact.display_message+"[/color]"
	if contact.image != null:
		image_label.texture = contact.image
