extends Room3D


@onready var music: FmodEventEmitter3D = %Music


func _ready() -> void:
	super()
	body_entered.connect(handle_player_entrance)


func handle_player_entrance(body: Node3D) -> void:
	remove_all_bounds(body)
	rotate_player(body)

	keep_camera_on_player(body)
	bind_camera_y(body)


func _on_scene_loader_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		music.stop()
