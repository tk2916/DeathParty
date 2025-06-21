extends Control

@export var label : RichTextLabel

@onready var resize_control = ResizableControl.new(self, label)

func _process(delta: float) -> void:
	resize_control.resize()
