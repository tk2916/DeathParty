extends CanvasLayer

@onready var main_pause_menu: VBoxContainer = $MarginContainer/MainPauseMenu
@onready var quit_menu: VBoxContainer = $MarginContainer/QuitMenu


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if main_pause_menu.visible:
			toggle_pause()
		elif quit_menu.visible:
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


func _on_quit_button_pressed() -> void:
	main_pause_menu.hide()
	quit_menu.show()


func _on_yes_quit_button_pressed() -> void:
	get_tree().quit()


func _on_no_quit_button_pressed() -> void:
	quit_menu.hide()
	main_pause_menu.show()
