extends ChoiceButton

@onready var resize_control = ResizableControl.new(self, text_label, true)

func _process(delta: float) -> void:
	resize_control.resize()
