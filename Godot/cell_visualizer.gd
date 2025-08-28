extends CanvasLayer

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_content_loader_menu"):
		visible = not visible
	elif Input.is_action_just_pressed("toggle_dev_menu"):
		visible = false
