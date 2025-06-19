extends "res://Assets/GUIPrefabs/DialogueLinePrefabs/dialogue_line_script.gd"

@onready var resize_control = ResizableControl.new(self, Text)

func _process(delta: float) -> void:
	resize_control.resize()
