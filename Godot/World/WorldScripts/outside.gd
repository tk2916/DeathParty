extends Area3D


func _on_body_entered(_body: Node3D) -> void:
	# Remove camera bounds
	GlobalCameraScript.remove_camera_bounds_LR.emit()
	GlobalCameraScript.remove_camera_bounds_y.emit()
	FmodServer.set_global_parameter_by_name_with_label("room", "outside")
