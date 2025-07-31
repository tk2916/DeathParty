class_name ItemInfoContainer extends Control

@onready var button : Button = $TextureRect/Button
@onready var description_label : RichTextLabel = $DescriptionBacker/Description

func _ready() -> void:
	button.pressed.connect(on_button_pressed)

func on_button_pressed():
	self.visible = false
	GuiSystem.show_journal()
	
func set_text(description : String):
	description_label.text = description
