extends CanvasLayer


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause()


func toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = !visible


# this connects the ⚙️ button in the bottom bar ui to the pause menu
# its commented out because right now it only works for pausing and not unpausing
#func _on_button_2_pressed() -> void:
	#toggle_pause()


func _on_resume_button_pressed() -> void:
	toggle_pause()
