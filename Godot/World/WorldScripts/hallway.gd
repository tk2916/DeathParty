extends Room3D

func _ready() -> void:
	super()
	GlobalPlayerScript.player_moved.connect(_calculate_progress_ratio)

func _on_body_entered(body: Node3D) -> void:
	# Remove camera bounds
	GlobalCameraScript.remove_all_bounds()
	GlobalCameraScript.camera_on_player.emit(false)
	
	GlobalCameraScript.bind_camera_path.emit(path_follow_node)
	rotate_player(body)
	# teleport player into foreground
	body.global_position = move_to_foreground(body)
