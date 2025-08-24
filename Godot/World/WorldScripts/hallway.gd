extends Room3D

func _ready() -> void:
	super()
	GlobalPlayerScript.player_moved.connect(_calculate_progress_ratio)
	body_entered.connect(handle_player_entrance)

func handle_player_entrance(body: Node3D) -> void:
	remove_all_bounds(body)
	rotate_player(body)
	bind_camera_path(body)
	
	move_player_to_foreground(body)
