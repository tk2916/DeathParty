extends Control

@export var contact_button : Button
@export var name_label : RichTextLabel
@export var time_label : RichTextLabel
@export var image_label : TextureRect

var message_app : MarginContainer
var contact : Resource

func on_pressed():
	message_app.onContactPress(contact)

func _ready() -> void:
	contact_button.pressed.connect(on_pressed)
	name_label.text = "[color=black]"+contact.name+"[/color]"
	time_label.text = "[color=black]"+SaveSystem.parse_time(contact.last_message_timestamp)+"[/color]"
	if contact.image != null:
		image_label.texture = contact.image
