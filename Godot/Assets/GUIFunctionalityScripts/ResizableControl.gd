class_name ResizableControl extends Node

var label : RichTextLabel
var control : Control
var resize_x : bool
var resize_y : bool
var padding_bottom : float

const MAX_WIDTH : float = 170
var theme_font : FontFile
var theme_font_size : int

func _init(_control : Control, _label : RichTextLabel, _resize_x : bool = true, _resize_y : bool = true, _padding_bottom : float = 0):
	control = _control
	label = _label
	resize_x = _resize_x
	resize_y = _resize_y
	padding_bottom = _padding_bottom
	
	theme_font = label.get_theme_font("normal")
	theme_font_size = label.get_theme_font_size("normal")

func resize():
	if self.resize_x:
		var actual_content_width : float = theme_font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, theme_font_size).x/2
		var content_width = min(actual_content_width, MAX_WIDTH)
		control.size.x = content_width
	else:
		await label.get_tree().process_frame
	
	control.custom_minimum_size.x = control.size.x
	label.custom_minimum_size.x = control.size.x
	label.size.x = control.size.x
	var content_height : int = label.get_content_height()
	var new_min_size_y = content_height + padding_bottom
	control.custom_minimum_size.y = new_min_size_y
