class_name ChoiceButton extends Control

@export var button : Button
@export var text_label : RichTextLabel

func set_text(text : String) -> void:
	text_label.text = text