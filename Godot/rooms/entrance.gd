extends Room3D

func _ready() -> void:
	super()
	GlobalPlayerScript.player_moved.connect(hide_entrance)
	body_entered.connect(handle_player_entrance)

func handle_player_entrance(body: Node3D) -> void:
	remove_all_bounds(body)
	rotate_player(body)
	
	keep_camera_on_player(body)
	bind_camera_LR(body)
	bind_camera_y(body, 2)


func hide_entrance(pos: Vector3) -> void:
	if(background_plane.distance_to(pos) < 0):
		visible = false
	else:
		visible = true
