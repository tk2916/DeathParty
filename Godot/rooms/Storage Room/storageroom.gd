extends Room3D

func _ready() -> void:
	super()
	body_entered.connect(handle_player_entrance)

func handle_player_entrance(body: Node3D) -> void:
	remove_all_bounds(body)
	rotate_player(body)
	
	keep_camera_on_player(body)
	bind_camera_LR(body)
	bind_camera_y(body)
	var storage_camera_offset_LR: Vector3 = Vector3(5, 0, 0)
	bind_camera_LR(body, room_area_center-storage_camera_offset_LR, room_area_center+storage_camera_offset_LR-Vector3(0.5,0,0))
