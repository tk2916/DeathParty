extends CanvasLayer


@onready var main_pause_menu : VBoxContainer = $MarginContainer/MainPauseMenu

@onready var resume_button : Button = $MarginContainer/MainPauseMenu/ResumeButton
@onready var settings_button : Button = $MarginContainer/MainPauseMenu/SettingsButton
@onready var quit_button : Button = $MarginContainer/MainPauseMenu/QuitButton

@onready var settings_menu : VBoxContainer = $MarginContainer/SettingsMenu
@onready var volume_slider : HSlider = $MarginContainer/SettingsMenu/GridContainer/VolumeSlider
@onready var volume_number : Label = $MarginContainer/SettingsMenu/GridContainer/VolumeNumber

@onready var quit_menu : VBoxContainer = $MarginContainer/QuitMenu
@onready var yes_quit_button : Button = $MarginContainer/QuitMenu/HBoxContainer/YesQuitButton


func _ready():
	volume_slider.value = Settings.volume


func _physics_process(delta : float) -> void:
	if Input.is_action_just_pressed("pause"):
		if main_pause_menu.visible:
			toggle_pause()

		elif settings_menu.visible:
			settings_menu.hide()
			main_pause_menu.show()
			settings_button.grab_focus()

		elif quit_menu.visible:
			quit_menu.hide()
			main_pause_menu.show()
			quit_button.grab_focus()


func toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = !visible
	
	if visible:
		resume_button.grab_focus()


# pause with the ⚙️ button in the UI
# this signal name is kinda unintuitive but we'll fix that when we add
# proper names for the nodes in the UI
func _on_button_2_pressed() -> void:
	toggle_pause()


func _on_resume_button_pressed() -> void:
	toggle_pause()


func _on_settings_button_pressed() -> void:
	main_pause_menu.hide()
	settings_menu.show()
	volume_slider.grab_focus()


func _on_volume_slider_value_changed(value : float) -> void:
	# im doing str(int()) cos without converting to an int first, it adds
	# a decimal after the float when its concatenated
	# and i think the other way to convert to an int uses % in the syntax
	# which would maybe look weird/hard to read since this is a percentage
	
	# (if anyone knows a nicer way to do this feel free to replace it lol)
	volume_number.text = str(int(volume_slider.value)) + "%"


func _on_volume_slider_drag_ended(value_changed : bool) -> void:
	Settings.set_volume(volume_slider.value)


func _on_settings_back_button_pressed() -> void:
	settings_menu.hide()
	main_pause_menu.show()
	settings_button.grab_focus()


func _on_quit_button_pressed() -> void:
	main_pause_menu.hide()
	quit_menu.show()
	yes_quit_button.grab_focus()


func _on_yes_quit_button_pressed() -> void:
	get_tree().quit()


func _on_no_quit_button_pressed() -> void:
	quit_menu.hide()
	main_pause_menu.show()
	quit_button.grab_focus()
