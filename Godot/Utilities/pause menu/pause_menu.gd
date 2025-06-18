extends CanvasLayer


@onready var main_pause_menu: VBoxContainer = $MarginContainer/MainPauseMenu

@onready var settings_menu: VBoxContainer = $MarginContainer/SettingsMenu
@onready var volume_slider: HSlider = $MarginContainer/SettingsMenu/GridContainer/VolumeSlider
@onready var volume_number: Label = $MarginContainer/SettingsMenu/GridContainer/VolumeNumber

@onready var quit_menu: VBoxContainer = $MarginContainer/QuitMenu


func _ready():
	volume_slider.value = Settings.volume


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if main_pause_menu.visible:
			toggle_pause()
		elif quit_menu.visible or settings_menu.visible:
			settings_menu.hide()
			quit_menu.hide()
			main_pause_menu.show()


func toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = !visible


# this connects the ⚙️ button in the bottom bar ui to the pause menu
# its commented out because right now it only works for pausing and not unpausing
#func _on_button_2_pressed() -> void:
	#toggle_pause()


func _on_resume_button_pressed() -> void:
	toggle_pause()


func _on_settings_button_pressed() -> void:
	main_pause_menu.hide()
	settings_menu.show()


func _on_volume_slider_value_changed(value: float) -> void:
	# im doing str(int()) cos without converting to an int first, it adds
	# a decimal after the float when its concatenated
	# and i think the other way to convert to an int uses % in the syntax
	# which would maybe look weird/hard to read since this is a percentage
	
	# (if anyone knows a nicer way to do this feel free to replace it lol)
	volume_number.text = str(int(volume_slider.value)) + "%"


func _on_volume_slider_drag_ended(value_changed: bool) -> void:
	Settings.set_volume(volume_slider.value)

func _on_settings_back_button_pressed() -> void:
	settings_menu.hide()
	main_pause_menu.show()


func _on_quit_button_pressed() -> void:
	main_pause_menu.hide()
	quit_menu.show()


func _on_yes_quit_button_pressed() -> void:
	get_tree().quit()


func _on_no_quit_button_pressed() -> void:
	quit_menu.hide()
	main_pause_menu.show()
