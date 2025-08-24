extends Control

@export var label : RichTextLabel
@export var resize_x : bool = true
@export var padding_bottom : float = 0

@onready var resize_control = ResizableControl.new(self, label, resize_x, true, padding_bottom)

func _ready() -> void:
	resize_control.resize()

func _on_text_resized() -> void:
	if resize_control:
		resize_control.resize()
