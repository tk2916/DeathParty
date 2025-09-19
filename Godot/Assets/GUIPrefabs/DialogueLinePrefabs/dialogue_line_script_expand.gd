class_name DialogueLineExpand extends DialogueLine

@export var control_to_resize : Control
@export var chat_backer : Control
@export var minimum_y_size : float = 0
var resize_control : ResizableControl

func _ready() -> void:
	resize_control = ResizableControl.new(control_to_resize, Text)
	# if Img and Img.texture: #extra padding if it is a message with a pfp
	# 	resize_control = ResizableControl.new(control_to_resize, Text, true, true, 5, 0, minimum_y_size)
	# else:
	# 	resize_control = ResizableControl.new(control_to_resize, Text)
	resize()
	print("Custom minimum size: ", self.control_to_resize.custom_minimum_size.y)
	custom_minimum_size.y = self.control_to_resize.custom_minimum_size.y

func _on_text_resized() -> void:
	print("On text resized: ", control_to_resize.name)
	if resize_control:
		resize()

func resize() -> void:
	resize_control.resize()
	resize_control.resize_component(chat_backer)
	self.control_to_resize.custom_minimum_size.y = max(self.control_to_resize.custom_minimum_size.y, minimum_y_size)
