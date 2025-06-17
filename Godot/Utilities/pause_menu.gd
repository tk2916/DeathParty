extends CanvasLayer


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == false:
			pause()
		else:
			resume()


func pause():
	get_tree().paused = true
	show()


func resume():
	get_tree().paused = false
	hide()
