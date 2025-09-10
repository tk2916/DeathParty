class_name ResizableControl extends Node

var label : RichTextLabel
var control : Control
var resize_x : bool
var resize_y : bool
var padding_bottom : float
var padding_horizontal : float

const MAX_WIDTH : float = 190
var theme_font : FontFile
var theme_font_size : int

func _init(_control : Control, _label : RichTextLabel, _resize_x : bool = true, _resize_y : bool = true, _padding_bottom : float = 5, _padding_horizontal : float = 0) -> void:
	control = _control
	label = _label
	resize_x = _resize_x
	resize_y = _resize_y
	padding_bottom = _padding_bottom
	padding_horizontal = _padding_horizontal
	
	theme_font = label.get_theme_font("normal")
	theme_font_size = label.get_theme_font_size("normal")

func resize() -> void:
	if not (control and label): return
	#print("Resizing-------", control.name)
	if self.resize_x:
		var actual_content_width : float = theme_font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, theme_font_size).x
		var content_width : float = clamp(actual_content_width, 0, MAX_WIDTH) + padding_horizontal
		control.size.x = content_width
	else:
		await label.get_tree().process_frame
	
	control.custom_minimum_size.x = control.size.x
	label.custom_minimum_size.x = control.size.x
	label.size.x = control.size.x
	if resize_y:
		var content_height : int = label.get_content_height()
		var new_min_size_y : float = content_height + padding_bottom
		control.custom_minimum_size.y = new_min_size_y
	print("Final custom min size: ", control.custom_minimum_size)

func resize_component(component : Control) -> void:
	if not (control and label and component): return
	component.custom_minimum_size = control.custom_minimum_size
