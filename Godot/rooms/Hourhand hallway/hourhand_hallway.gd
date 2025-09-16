extends Room3D

func _ready() -> void:
	super()
	body_entered.connect(handle_player_entrance)

func handle_player_entrance(body: Node3D) -> void:
	remove_all_bounds(body)
	rotate_player(body)
	
	keep_camera_on_player(body)
	var offset: Vector3 = Vector3(0, 0, 14.95)
	bind_camera_LR(body, room_area_center+offset, room_area_center-offset)
	bind_camera_y(body, -0.2, -0.2)
	bind_camera_depth(body, room_area_center, room_area_center)
	var boundaries : Node3D = $Boundaries
	var floor_node : Node3D = $Floor
	boundaries.set_rotation(Vector3.ZERO)
	floor_node.set_rotation(Vector3.ZERO)
