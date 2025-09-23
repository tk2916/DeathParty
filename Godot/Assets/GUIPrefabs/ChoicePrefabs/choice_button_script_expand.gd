class_name PhoneChoiceButton extends ChoiceButton

@onready var panel : Panel = $ChoicePanel
@onready var resize_control : ResizableControl = ResizableControl.new(self, self.text_label, false, true, 20, 20)
@onready var stylebox : StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()

@export var normal_color : Color = Color("81d27f")
@export var hover_color : Color = Color("599c58")
@export var tween_time : float = .2

func _ready() -> void:
	#otherwise the tweens affect all instances
	panel.add_theme_stylebox_override("panel", stylebox)
	stylebox.bg_color = normal_color
	resize_control.resize()
	resize_control.resize_component(panel)
	
func tween_to_color(color : Color) -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(stylebox, "bg_color", color, tween_time)

func _on_button_mouse_entered() -> void:
	tween_to_color(hover_color)

func _on_button_mouse_exited() -> void:
	tween_to_color(normal_color)

#region Keyboard/controller naviagtion visuals
func _on_button_focus_entered() -> void:
	tween_to_color(hover_color)
	
func _on_button_focus_exited() -> void:
	tween_to_color(normal_color)
#endregion

func _on_rich_text_label_resized() -> void:
	if resize_control:
		resize_control.resize()
		resize_control.resize_component(panel)

func destroy() -> void:
	resize_control = null
	self.queue_free()
