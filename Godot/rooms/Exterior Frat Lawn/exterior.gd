extends Room3D

func _ready() -> void:
	super()
	body_entered.connect(handle_player_entrance)

func handle_player_entrance(body: Node3D) -> void:
	remove_all_bounds(body)
	rotate_player(body)
	
	keep_camera_on_player(body)
	bind_camera_LR(body)
	bind_camera_y(body, 2.5)
	set_camera_offset(Vector3(0, 0, 0))
