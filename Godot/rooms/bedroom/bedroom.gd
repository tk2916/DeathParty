extends Room3D

@export var play_button: Button
@export var quit_button: Button
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
	quit_button.pressed.connect(on_quit_button_pressed)


func _physics_process(delta: float) -> void:
	pass


func handle_player_entrance(body: Node3D) -> void:
	GlobalCameraScript.move_camera_jump.emit()
	remove_all_bounds(body)
	rotate_player(body)
	bind_camera_path(body)
	#var bedroom_camera_offset_LR: Vector3 = Vector3(.61, 0, 0)
	#bind_camera_LR(body, room_area_center-bedroom_camera_offset_LR, room_area_center+bedroom_camera_offset_LR)
	bind_camera_y(body, 1.2, 1.6)
	var bedroom_camera_depth_point: Vector3 = Vector3(0, 0, 34.4)
	bind_camera_depth(body, Vector3.ZERO, bedroom_camera_depth_point)
	
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
	play_button.visible = false
	quit_button.visible = false

	var tween: Tween = get_tree().create_tween()
	tween.tween_property(fade_title, "modulate:a", 0, 1.3)
	await tween.finished
	title_screen.visible = false
	await get_tree().create_timer(1).timeout
	
	closet.visible = true
	var tween2: Tween = get_tree().create_tween()
	tween2.tween_property(path_follow_node, "progress_ratio", 1, 1.2)
	await tween2.finished
	
	var bedroom_camera_offset_LR: Vector3 = Vector3(.61, 0, 0)
	bind_camera_LR(null, room_area_center-bedroom_camera_offset_LR, room_area_center+bedroom_camera_offset_LR)
	bind_camera_y(null, 1.2, 1.35)
	
	GlobalCameraScript.camera_on_player.emit(true)
	intro_finished.emit()


func on_quit_button_pressed() -> void:
	get_tree().quit()
