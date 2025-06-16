extends Control

@export var button : Button
@export var text_label : RichTextLabel
var choice_text : String
var choice_text_color : String
var text_properties : Resource

var redirect : String

signal selected

func _button_pressed():
	print("Choice button pressed: ", redirect)
	selected.emit(redirect, choice_text)

func _ready() -> void:
	if text_properties["default_choice_color"]:
		choice_text_color = text_properties["default_choice_color"]
	text_label.add_theme_font_size_override("normal_font_size", text_properties["choice_size"])
	if text_properties["prefix_choices_with_player_name"]:
		text_label.text = "[color="+choice_text_color+"] YOU: "+choice_text+"[/color]"
	else:
		text_label.text = "[color="+choice_text_color+"]"+choice_text+"[/color]"
	button.pressed.connect(_button_pressed)

func _process(delta):
	var content_height : int = text_label.get_content_height()
	var content_width : int = text_label.get_content_width()
	
	self.custom_minimum_size.y = content_height
	self.custom_minimum_size.x = content_width
