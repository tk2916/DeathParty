extends DialogueLine

@export var control_to_resize : Control
@export var chat_backer : Control
@onready var resize_control : ResizableControl = ResizableControl.new(control_to_resize, Text)

func _ready() -> void:
	resize_control.resize()
	resize_control.resize_component(chat_backer)
	print("Custom minimum size: ", self.control_to_resize.custom_minimum_size.y)
	custom_minimum_size.y = self.control_to_resize.custom_minimum_size.y

func _on_text_resized() -> void:
	if resize_control:
		resize_control.resize()
		resize_control.resize_component(chat_backer)
