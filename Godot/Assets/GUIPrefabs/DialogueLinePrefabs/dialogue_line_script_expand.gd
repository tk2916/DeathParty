extends "res://Assets/GUIPrefabs/DialogueLinePrefabs/dialogue_line_script.gd"

func _ready() -> void:
	ResizableControl.new(self, Text)

#func _process(delta):
	#var content_height : int = Text.get_content_height()
	#var content_width : int = Text.get_content_width()
	#
	#self.custom_minimum_size.y = content_height
	#self.custom_minimum_size.x = content_height
		
