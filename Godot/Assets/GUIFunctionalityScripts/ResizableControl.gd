class_name ResizableControl extends Node

var label : RichTextLabel
var control : Control
var resize_x : bool
var padding_bottom : float

func _init(_control : Control, _label : RichTextLabel, _resize_x : bool = true, _resize_y : bool = true, _padding_bottom : float = 0):
	control = _control
	label = _label
	resize_x = _resize_x
	padding_bottom = _padding_bottom

func resize():
	var content_height : int = label.get_content_height()
	control.custom_minimum_size.y = content_height + padding_bottom
	
	if self.resize_x:
		var content_width : int = label.get_content_width()
		control.custom_minimum_size.x = content_width
