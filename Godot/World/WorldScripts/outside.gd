extends "res://Utilities/scripts/define_camera_bounds.gd"


func _on_body_entered(body: Node3D) -> void:
	# Remove camera bounds
	GlobalCameraScript.remove_all_bounds()
	
	rotate_player(body)
	GlobalCameraScript.camera_on_player.emit(true)

	FmodServer.set_global_parameter_by_name_with_label("room", "outside")
