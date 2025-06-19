extends "res://Assets/GUIPrefabs/ChoicePrefabs/choice_button_script.gd"

@onready var resize_control = ResizableControl.new(self, text_label)

func _process(delta: float) -> void:
	resize_control.resize()
	
