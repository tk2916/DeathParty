extends Room3D


func _on_body_entered(body: Node3D) -> void:
	GlobalCameraScript.remove_all_bounds()
	# Define camera bounds 
	GlobalCameraScript.bind_camera_LR.emit(left_bound, right_bound, basis)
	GlobalCameraScript.bind_camera_y.emit(lower_bound, upper_bound)
	rotate_player(body)
	
	FmodServer.set_global_parameter_by_name_with_label("room", "back room")
