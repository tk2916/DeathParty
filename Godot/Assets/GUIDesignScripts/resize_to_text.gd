extends Panel

@export var label : RichTextLabel

func _process(delta):
	var content_height = label.get_content_height()
	self.size.y = content_height
