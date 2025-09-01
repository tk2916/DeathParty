extends CanvasLayer


@onready var bottom_ui_bar : CanvasLayer = %CanvasLayer

@onready var main_pause_menu : VBoxContainer = %MainPauseMenu

@onready var resume_button : Button = %ResumeButton
@onready var settings_button : Button = %SettingsButton
@onready var quit_button : Button = %QuitButton

@onready var settings_menu : VBoxContainer = %SettingsMenu
@onready var volume_slider : HSlider = %VolumeSlider
@onready var volume_number : Label = %VolumeNumber
@onready var input_button: Button = %InputButton
@onready var video_button: Button = %VideoButton

@onready var input_menu : VBoxContainer = %InputMenu
@onready var input_back_button : Button = %InputBackButton

@onready var video_menu : VBoxContainer = %VideoMenu
@onready var video_back_button : Button = %VideoBackButton

@onready var quit_menu : VBoxContainer = %QuitMenu
@onready var yes_quit_button : Button = %YesQuitButton

@onready var click_sound : FmodEventEmitter2D = %ClickSound


func _ready() -> void:
	volume_slider.value = Settings.volume

	# connect pressed signal of all buttons in the scene to a func that plays ui sfx
	for button in get_tree().get_nodes_in_group("buttons"):
		if button is BaseButton:
			button.pressed.connect(on_any_button_pressed)

		if button is TabContainer:
			button.tab_clicked.connect(func(tab : int): on_any_button_pressed())


func _physics_process(_delta : float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().get_first_node_in_group("title_screen").visible == true:
			return

		elif get_tree().get_first_node_in_group("journal") != null:
			GuiSystem.hide_journal()

		elif GuiSystem.in_phone == true:
			GuiSystem.hide_gui("Phone")

		elif settings_menu.visible:
			settings_menu.hide()
			main_pause_menu.show()
			settings_button.grab_focus()
			click_sound.play()

		elif input_menu.visible:
			input_menu.hide()
			settings_menu.show()
			input_button.grab_focus()
			click_sound.play()

		elif video_menu.visible:
			video_menu.hide()
			settings_menu.show()
			video_button.grab_focus()
			click_sound.play()

		elif quit_menu.visible:
			quit_menu.hide()
			main_pause_menu.show()
			quit_button.grab_focus()
			click_sound.play()

		else:
			toggle_pause()
			click_sound.play()


func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused

	visible = !visible
	bottom_ui_bar.visible = !bottom_ui_bar.visible

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
	input_button.grab_focus()


func _on_input_button_pressed() -> void:
	settings_menu.hide()
	input_menu.show()
	input_back_button.grab_focus()


func _on_video_button_pressed() -> void:
	settings_menu.hide()
	video_menu.show()
	video_back_button.grab_focus()


func _on_volume_slider_value_changed(value : float) -> void:
	# im doing str(int()) cos without converting to an int first, it adds
	# a decimal after the float when its concatenated
	# and i think the other way to convert to an int uses % in the syntax
	# which would maybe look weird/hard to read since this is a percentage

	# (if anyone knows a nicer way to do this feel free to replace it lol)
	volume_number.text = str(int(volume_slider.value)) + "%"

	Settings.set_volume(volume_slider.value)


func _on_volume_slider_drag_ended(_value_changed : bool) -> void:
	Settings.set_volume(volume_slider.value)


func _on_settings_back_button_pressed() -> void:
	settings_menu.hide()
	main_pause_menu.show()
	settings_button.grab_focus()


func _on_input_back_button_pressed() -> void:
	input_menu.hide()
	settings_menu.show()
	input_button.grab_focus()


func _on_video_back_button_pressed() -> void:
	video_menu.hide()
	settings_menu.show()
	video_button.grab_focus()


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


# NOTE: the name of this func could maybe be clearer if anyone has ideas
# (i didnt want to just name it 'on button pressed' since thats close
# to the signal for a single button which could be confusing)
func on_any_button_pressed() -> void:
	click_sound.play()
