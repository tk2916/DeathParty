extends "res://Assets/GUIPrefabs/ChoicePrefabs/choice_button_script.gd"

func _ready() -> void:
	ResizableControl.new(self, text_label)

#func _process(delta):
	#var content_height : int = text_label.get_content_height()
	#var content_width : int = text_label.get_content_width()
	#
	#self.custom_minimum_size.y = content_height
	#self.custom_minimum_size.x = content_width
