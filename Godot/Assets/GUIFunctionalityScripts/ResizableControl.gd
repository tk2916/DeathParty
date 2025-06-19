class_name ResizableControl

var label : RichTextLabel
var control : Control

func _init(_control : Control, _label : RichTextLabel):
	control = _control
	label = _label

func _process(delta):
	var content_height : int = label.get_content_height()
	var content_width : int = label.get_content_width()
	
	control.custom_minimum_size.y = content_height
	control.custom_minimum_size.x = content_width
