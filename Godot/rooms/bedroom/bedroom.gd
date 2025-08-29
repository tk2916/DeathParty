extends Room3D

@export var play_button: Button
@export var fade_title: Control
@export var title_screen: CanvasLayer
@export var closet: Node3D

@onready var music: FmodEventEmitter3D = %Music
@onready var look_straight: Vector3 = Vector3(path_follow_node.global_position.x, path_follow_node.global_position.y, -basis.z.z)

signal intro_finished


func _ready() -> void:
	super()
	GlobalCameraScript.move_camera_jump.emit()
	body_entered.connect(handle_player_entrance)
	play_button.pressed.connect(_on_play)


func _physics_process(delta: float) -> void:
	pass


func handle_player_entrance(body: Node3D) -> void:
	GlobalCameraScript.move_camera_jump.emit()
	remove_all_bounds(body)
	rotate_player(body)
	
	bind_camera_path(body)
	bind_camera_LR(body)
	bind_camera_y(body, 1.2, 1.6)
	#await get_tree().create_timer(1).timeout
	await GlobalCameraScript.finished_moving
	GlobalCameraScript.move_camera_smooth.emit()
	
	path_follow_node.look_at(look_straight) # Look straight ahead
	# ^ currently unneeded due to rotation mode None in path follow node

	#keep_camera_on_player(body)
	#bind_camera_y(body, 1.5, 1.5)


func _on_scene_loader_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		music.stop()


func _on_play() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(fade_title, "modulate:a", 0, 1.3)
	await tween.finished
	title_screen.visible = false
	await get_tree().create_timer(1).timeout
	
	closet.visible = true
	var tween2: Tween = get_tree().create_tween()
	tween2.tween_property(path_follow_node, "progress_ratio", 1, 1.2)
	await tween2.finished
	
	GlobalCameraScript.camera_on_player.emit(true)
	intro_finished.emit()
