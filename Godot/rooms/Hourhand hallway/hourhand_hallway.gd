extends Room3D

func _ready() -> void:
	super()
	body_entered.connect(handle_player_entrance)

func handle_player_entrance(body: Node3D) -> void:
	remove_all_bounds(body)
	
	keep_camera_on_player(body)
	var hourhand_camera_offset_LR: Vector3 = Vector3(0, 0, 20)
	bind_camera_LR(body, room_area_center+hourhand_camera_offset_LR, room_area_center-hourhand_camera_offset_LR)
	bind_camera_y(body, -0.4, -0.4)
	bind_camera_depth(body, room_area_center, room_area_center)
	var boundaries : Node3D = $Boundaries
	var floor_node : Node3D = $Floor
	boundaries.set_rotation(Vector3.ZERO)
	floor_node.set_rotation(Vector3.ZERO)
