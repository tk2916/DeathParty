extends Control

@export var label : RichTextLabel
@export var resize_x : bool = true
@export var padding_bottom : float = 0

@onready var resize_control = ResizableControl.new(self, label, resize_x, padding_bottom)

func _process(delta: float) -> void:
	resize_control.resize()
