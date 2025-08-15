extends Room3D

@onready var music: FmodEventEmitter3D = %Music

func _ready() -> void:
	super()
	#GlobalPlayerScript.player_moved.connect(_calculate_progress_ratio)
	body_entered.connect(handle_player_entrance)


func _physics_process(delta: float) -> void:
	var look_straight: Vector3 = Vector3(path_follow_node.position.x, path_follow_node.position.y, -basis.z.z)
	path_follow_node.look_at(look_straight) # Look straight ahead
	
	if Input.is_action_just_pressed("interact"):
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(path_follow_node, "progress_ratio", 1, 0.7)


func handle_player_entrance(body: Node3D) -> void:
	remove_all_bounds(body)
	rotate_player(body)
	
	bind_camera_path(body)
	
	var look_straight: Vector3 = Vector3(path_follow_node.position.x, path_follow_node.position.y, body.position.z)
	path_follow_node.look_at(look_straight) # Look straight ahead


func _on_scene_loader_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		music.stop()
