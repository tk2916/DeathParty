extends "res://Utilities/scripts/define_camera_bounds.gd"

func _on_body_entered(body: Node3D) -> void:
	# Define camera bounds 
	GlobalCameraScript.bind_camera_LR.emit(left_bound, right_bound, basis)
	GlobalCameraScript.bind_camera_y.emit(lower_bound, upper_bound)
	body.transform.basis = Basis.looking_at(basis.z, basis.y, true)
	# teleport player into foreground
	body.global_position = move_to_foreground(body)
