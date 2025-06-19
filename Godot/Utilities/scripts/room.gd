## Emits signal when player is in room
extends Area3D

signal player_present(new_camera_location: Vector3)


func _on_body_entered(_body: Node3D) -> void:
	GlobalCameraScript.move_camera_smooth.emit($RoomCameraLocation.global_position)
	GlobalCameraScript.camera_on_player.emit(false)


func _on_body_exited(_body: Node3D) -> void:
	GlobalCameraScript.camera_on_player.emit(true)
