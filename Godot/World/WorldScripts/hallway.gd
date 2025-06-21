extends "res://Utilities/scripts/define_camera_bounds.gd"

func _on_body_entered(body: Node3D) -> void:
	# Define camera bounds 
	GlobalCameraScript.bind_camera_LR.emit(left_bound, right_bound, basis)
	GlobalCameraScript.bind_camera_y.emit(lower_bound, upper_bound)
	body.transform.basis = Basis.looking_at(basis.z, basis.y, true)
	# teleport player into foreground
	body.global_position = move_to_foreground(body)


func move_to_foreground(body: Node3D) -> Vector3:
	var initial_position: Vector3 = body.global_position
	initial_position *= abs((basis.x + basis.y))
	var new_position: Vector3 = initial_position
	new_position += global_position * basis.z
	
	return new_position
