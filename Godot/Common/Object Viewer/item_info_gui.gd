class_name ItemInfoContainer extends Control

@export var object_viewer : ObjectViewer
@onready var button : Button = $ItemInfoExit/Button
@onready var description_label : RichTextLabel = $DescriptionBacker/Description

func _ready() -> void:
	button.pressed.connect(on_button_pressed)

func on_button_pressed():
	object_viewer.close_item_info()
	GuiSystem.show_journal(true)
	
func set_text(description : String):
	description_label.text = description
