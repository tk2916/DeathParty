extends Control

@onready var fullscreen_option_button : OptionButton = %FullscreenOptionButton
@onready var resolution_option_button: OptionButton = %ResolutionOptionButton
@onready var monitor_option_button : OptionButton = %MonitorOptionButton
@onready var vsync_option_button : OptionButton = %VSyncOptionButton

@onready var scale_slider : HSlider = %ScaleSlider
@onready var scale_label : Label = %ScaleLabel

@onready var upscale_option_button : OptionButton = %UpscaleOptionButton
@onready var sharpness_label : Label = %SharpnessLabel
@onready var sharpness_container : Container = %SharpnessContainer
@onready var sharpness_slider : HSlider = %SharpnessSlider
@onready var sharpness_spin_box : SpinBox = %SharpnessSpinBox

@onready var fps_slider : HSlider = %FPSSlider
@onready var fps_spin_box : SpinBox = %FPSSpinBox
@onready var fps_limit_off_label: Label = %FPSLimitOffLabel

@onready var filtering_option_button : OptionButton = %FilteringOptionButton
@onready var aa_option_button : OptionButton = %AAOptionButton
@onready var lod_option_button : OptionButton = %LODOptionButton
@onready var shadow_size_option_button : OptionButton = %ShadowSizeOptionButton

@onready var ssao_option_button : OptionButton = %SSAOOptionButton

var last_monitor_count : int


func _ready() -> void:
	fullscreen_option_button.selected = Settings.fullscreen

	# get monitor res and population resolution option button with
	# resolutions it can display
	for res in Settings.resolutions:
		if DisplayServer.screen_get_size().y >= res:
			resolution_option_button.add_item(str(res) + "p")

	# set initial resolution option button setting to match res from cfg

	# doing it in this weird way since the options here are dynamic
	# based on player's monitor res, so the index of the resolutions in the menu
	# will vary

	# lmk if thats a dumb way to do it lol
	for i in range(resolution_option_button.get_item_count()):
		var item_text: String = resolution_option_button.get_item_text(i)
		var item_res: int = int(item_text.trim_suffix("p"))

		if item_res == Settings.resolution:
			resolution_option_button.select(i)

	vsync_option_button.selected = Settings.vsync
	
	scale_slider.value = Settings.scale
	upscale_option_button.selected = Settings.upscale
	
	sharpness_slider.value = Settings.sharpness
	sharpness_spin_box.value = sharpness_slider.value
	hide_or_show_fsr_sharpness(upscale_option_button.selected)
	
	fps_slider.value = Settings.fps
	fps_spin_box.value = fps_slider.value
	hide_or_show_fps_limit_label(fps_spin_box.value)

	filtering_option_button.selected = Settings.filtering
	aa_option_button.selected = Settings.aa
	lod_option_button.selected = Settings.lod
	shadow_size_option_button.selected = Settings.shadows
	
	ssao_option_button.selected = Settings.ssao
	
	set_monitor_options()


# MONITOR SELECTION

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


# PRESET BUTTONS

func _on_preset_1_pressed() -> void:
	aa_option_button.selected = 0
	aa_option_button.emit_signal("item_selected", aa_option_button.selected)
	shadow_size_option_button.selected = 0
	shadow_size_option_button.emit_signal("item_selected", shadow_size_option_button.selected)
	ssao_option_button.selected = 0
	ssao_option_button.emit_signal("item_selected", ssao_option_button.selected)
	lod_option_button.selected = 1
	lod_option_button.emit_signal("item_selected", lod_option_button.selected)


func _on_preset_2_pressed() -> void:
	aa_option_button.selected = 0
	aa_option_button.emit_signal("item_selected", aa_option_button.selected)
	shadow_size_option_button.selected = 1
	shadow_size_option_button.emit_signal("item_selected", shadow_size_option_button.selected)
	ssao_option_button.selected = 2
	ssao_option_button.emit_signal("item_selected", ssao_option_button.selected)
	lod_option_button.selected = 1
	lod_option_button.emit_signal("item_selected", lod_option_button.selected)


func _on_preset_3_pressed() -> void:
	aa_option_button.selected = 3
	aa_option_button.emit_signal("item_selected", aa_option_button.selected)
	shadow_size_option_button.selected = 2
	shadow_size_option_button.emit_signal("item_selected", shadow_size_option_button.selected)
	ssao_option_button.selected = 4
	ssao_option_button.emit_signal("item_selected", ssao_option_button.selected)
	lod_option_button.selected = 2
	lod_option_button.emit_signal("item_selected", lod_option_button.selected)


func _on_preset_4_pressed() -> void:
	aa_option_button.selected = 4
	aa_option_button.emit_signal("item_selected", aa_option_button.selected)
	shadow_size_option_button.selected = 2
	shadow_size_option_button.emit_signal("item_selected", shadow_size_option_button.selected)
	ssao_option_button.selected = 5
	ssao_option_button.emit_signal("item_selected", ssao_option_button.selected)
	lod_option_button.selected = 3
	lod_option_button.emit_signal("item_selected", lod_option_button.selected)


func _on_preset_5_pressed() -> void:
	aa_option_button.selected = 5
	aa_option_button.emit_signal("item_selected", aa_option_button.selected)
	shadow_size_option_button.selected = 3
	shadow_size_option_button.emit_signal("item_selected", shadow_size_option_button.selected)
	ssao_option_button.selected = 5
	ssao_option_button.emit_signal("item_selected", ssao_option_button.selected)
	lod_option_button.selected = 3
	lod_option_button.emit_signal("item_selected", lod_option_button.selected)


# DISPLAY SETTINGS

func _on_fullscreen_option_button_item_selected(value : int) -> void:
	Settings.set_fullscreen(value)


func _on_resolution_option_button_item_selected(index: int) -> void:
	var res = int(resolution_option_button.text.trim_suffix("p"))
	Settings.set_resolution(res)


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


func _on_upscale_option_button_item_selected(index: int) -> void:
	hide_or_show_fsr_sharpness(index)
	Settings.set_upscale(index)


func _on_sharpness_slider_value_changed(value: float) -> void:
	if sharpness_slider.has_focus():
		sharpness_spin_box.value = value


func _on_sharpness_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		sharpness_spin_box.value = sharpness_slider.value
		Settings.set_sharpness(sharpness_spin_box.value)


func _on_sharpness_spin_box_value_changed(value: float) -> void:
	if !sharpness_slider.has_focus():
		sharpness_slider.value = value
		Settings.set_sharpness(sharpness_spin_box.value)


func hide_or_show_fsr_sharpness(mode: int) -> void:
	if mode > 0:
		sharpness_label.visible = true
		sharpness_container.visible = true
		#sharpness_slider.editable = true
		#sharpness_spin_box.editable = true
	else:
		sharpness_label.visible = false
		sharpness_container.visible = false
		#sharpness_slider.editable = false
		#sharpness_spin_box.editable = false


func _on_fps_slider_value_changed(value: float) -> void:
	if fps_slider.has_focus():
		fps_spin_box.value = value
		hide_or_show_fps_limit_label(fps_spin_box.value)


func _on_fps_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		fps_slider.value = clamp_fps_value(fps_slider.value)
		fps_spin_box.value = fps_slider.value
		hide_or_show_fps_limit_label(fps_spin_box.value)
		#Settings.set_fps(clamp_fps_value(fps_slider.value))
		Settings.set_fps(fps_slider.value)


func _on_fps_spin_box_value_changed(value: float) -> void:
	if !fps_slider.has_focus():
		# Maybe don't clamp for spinbox change since it's more deliberate?
		#fps_spin_box.value = clamp_fps_value(value)
		hide_or_show_fps_limit_label(fps_spin_box.value)
		fps_slider.value = fps_spin_box.value
		#Settings.set_fps(clamp_fps_value(fps_spin_box.value))
		Settings.set_fps(fps_spin_box.value)


func clamp_fps_value(value: float) -> float:
	if value > 0 && value < 30:
		return 30
	return value


func hide_or_show_fps_limit_label(value : float) -> void:
	if value == 0:
		fps_spin_box.hide()
		fps_limit_off_label.show()
	else:
		fps_limit_off_label.hide()
		fps_spin_box.show()


# QUALITY SETTINGS

func _on_filtering_option_button_item_selected(index: int) -> void:
	Settings.set_filtering(index)


func _on_aa_option_button_item_selected(index: int) -> void:
	Settings.set_aa(index)


func _on_lod_option_button_item_selected(index: int) -> void:
	Settings.set_lod(index)


func _on_shadow_size_option_button_item_selected(index: int) -> void:
	Settings.set_shadows(index)


func _on_ssao_option_button_item_selected(index: int) -> void:
	Settings.set_ssao(index)
