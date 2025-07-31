extends Room3D

@export var things_to_hide : Node3D

func _on_body_entered(body: Node3D) -> void:
	GlobalCameraScript.camera_on_player.emit(true)
	GlobalCameraScript.remove_all_bounds()
	
	GlobalCameraScript.bind_camera_LR.emit(left_bound, right_bound, basis)
	GlobalCameraScript.bind_camera_y.emit(lower_bound, upper_bound)
	rotate_player(body)

	FmodServer.set_global_parameter_by_name_with_label("room", "upstairs room")


func _on_door_enter_door() -> void:
	things_to_hide.visible = false


func _on_door_return_through_door() -> void:
	things_to_hide.visible = true
