extends "res://Utilities/scripts/define_camera_bounds.gd"


func _on_body_entered(body: Node3D) -> void:
	rotate_player(body)
	GlobalCameraScript.camera_on_player.emit(true)
	# Remove camera bounds
	GlobalCameraScript.remove_camera_bounds_LR.emit()
	GlobalCameraScript.remove_camera_bounds_y.emit()
	GlobalCameraScript.remove_camera_bounds_depth.emit()

	FmodServer.set_global_parameter_by_name_with_label("room", "outside")
