extends Control

@export var label : RichTextLabel

func _process(delta):
	var content_height : int = label.get_content_height()
	var content_width : int = label.get_content_width()
	var line_count : int = label.get_line_count()
	
	self.custom_minimum_size.y = content_height
	self.custom_minimum_size.x = content_width
	if line_count > 1:
		print("Adjusting width: ", content_width)
		
