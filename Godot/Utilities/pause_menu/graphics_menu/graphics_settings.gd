extends Control


@onready var fullscreen_option_button : OptionButton = %FullscreenOptionButton
@onready var monitor_option_button : OptionButton = %MonitorOptionButton
@onready var scale_slider : HSlider = %ScaleSlider
@onready var scale_label : Label = %ScaleLabel

var last_monitor_count : int


func _ready() -> void:
	fullscreen_option_button.selected = Settings.fullscreen
	scale_slider.value = Settings.scale
	
	set_monitor_options()


func _process(_delta: float) -> void:
	if DisplayServer.get_screen_count() != last_monitor_count:
		set_monitor_options()


func set_monitor_options() -> void:
	monitor_option_button.clear()
	
	last_monitor_count = DisplayServer.get_screen_count()
	var select_i : int = 0
	for i in range(last_monitor_count):
		var is_current := ""
		if i == DisplayServer.window_get_current_screen():
			is_current = " (Current)"
			select_i = i
		monitor_option_button.add_item("Monitor %s%s" % [i,is_current])
	
	monitor_option_button.select(select_i)


func _on_fullscreen_option_button_item_selected(value : int) -> void:
	Settings.set_fullscreen(value)


func _on_monitor_option_button_item_selected(index: int) -> void:
	Settings.set_monitor(index)
	set_monitor_options()


func _on_scale_slider_value_changed(value: float) -> void:
	scale_label.text = "%d%%" % (value * 100)


func _on_scale_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Settings.set_scale(scale_slider.value)
