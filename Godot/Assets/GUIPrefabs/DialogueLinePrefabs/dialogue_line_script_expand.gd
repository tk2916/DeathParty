extends "res://Assets/GUIPrefabs/DialogueLinePrefabs/dialogue_line_script.gd"

func _ready() -> void:
	ResizableControl.new(self, Text)
