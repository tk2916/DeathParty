extends Control


@onready var fullscreen_option_button : OptionButton = %FullscreenOptionButton
@onready var monitor_option_button : OptionButton = %MonitorOptionButton
@onready var vsync_option_button : OptionButton = %VSyncOptionButton

@onready var scale_slider : HSlider = %ScaleSlider
@onready var scale_label : Label = %ScaleLabel

@onready var fps_slider : HSlider = %FPSSlider
@onready var fps_spin_box : SpinBox = %FPSSpinBox
@onready var fps_limit_off_label: Label = %FPSLimitOffLabel

@onready var filtering_option_button : OptionButton = %FilteringOptionButton
@onready var aa_option_button : OptionButton = %AAOptionButton

var last_monitor_count : int


func _ready() -> void:
	fullscreen_option_button.selected = Settings.fullscreen
	vsync_option_button.selected = Settings.vsync
	scale_slider.value = Settings.scale

	fps_slider.value = Settings.fps
	fps_spin_box.value = fps_slider.value
	hide_or_show_fps_limit_label(fps_spin_box.value)

	filtering_option_button.selected = Settings.filtering
	aa_option_button.selected = Settings.aa
	
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


func _on_v_sync_option_button_item_selected(index: int) -> void:
	Settings.set_vsync(index)


func _on_scale_slider_value_changed(value: float) -> void:
	scale_label.text = "%d%%" % (value * 100)


func _on_scale_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Settings.set_scale(scale_slider.value)


func _on_fps_slider_value_changed(value: float) -> void:
	if fps_slider.has_focus():
		fps_spin_box.value = value
		hide_or_show_fps_limit_label(fps_spin_box.value)


func _on_fps_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		#fps_slider.value = clamp_fps_value(fps_slider.value)
		fps_spin_box.value = fps_slider.value
		hide_or_show_fps_limit_label(fps_spin_box.value)
		Settings.set_fps(clamp_fps_value(fps_slider.value))


func _on_fps_spin_box_value_changed(value: float) -> void:
	if !fps_slider.has_focus():
		#fps_spin_box.value = clamp_fps_value(value)
		hide_or_show_fps_limit_label(fps_spin_box.value)
		fps_slider.value = fps_spin_box.value
		Settings.set_fps(clamp_fps_value(fps_spin_box.value))


func clamp_fps_value(value: float) -> float:
	if value > 0 && value < 20:
		return 20
	return value


func hide_or_show_fps_limit_label(value : float) -> void:
	if value == 0:
		fps_spin_box.hide()
		fps_limit_off_label.show()
	else:
		fps_limit_off_label.hide()
		fps_spin_box.show()


func _on_filtering_option_button_item_selected(index: int) -> void:
	Settings.set_filtering(index)


func _on_aa_option_button_item_selected(index: int) -> void:
	Settings.set_aa(index)
