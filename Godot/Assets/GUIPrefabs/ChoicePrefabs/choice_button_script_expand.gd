extends "res://Assets/GUIPrefabs/ChoicePrefabs/choice_button_script.gd"

func _ready() -> void:
	ResizableControl.new(self, text_label)
