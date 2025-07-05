extends "res://Utilities/scripts/define_camera_bounds.gd"


func _on_body_entered(_body: Node3D) -> void:
	GlobalCameraScript.remove_camera_bounds_path.emit()
	GlobalCameraScript.remove_camera_bounds_depth.emit()
	# Define camera bounds 
	GlobalCameraScript.bind_camera_LR.emit(left_bound, right_bound, basis)
	GlobalCameraScript.bind_camera_y.emit(lower_bound, upper_bound)
	
	FmodServer.set_global_parameter_by_name_with_label("room", "back room")
