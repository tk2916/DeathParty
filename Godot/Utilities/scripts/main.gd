extends Node3D

var PLAYER_CAMERA_FOLLOW_SPEED : float = 3.5
var CAMERA_TRANSITION_SPEED : float = 2
var camera_speed: float = PLAYER_CAMERA_FOLLOW_SPEED

var camera_location_node : Node3D
var camera_location : Vector3
var camera_on_player : bool = true
var camera_smooth: bool = true

var camera_bound_LR: bool = false
var camera_left_bound: Plane
var camera_right_bound: Plane
var camera_parent_basis : Basis

var camera_bound_y: bool = false
var camera_lower_bound_y: float = 0.0
var camera_upper_bound_y: float = 0.0

var main_camera : Camera3D

# Constantly moves the camera's location
func _ready() -> void:
	main_camera = $MainCamera
	camera_location_node = $Player/PlayerCameraLocation
	camera_location = camera_location_node.global_position
	main_camera.make_current()
	
	GlobalCameraScript.move_camera_smooth.connect(_move_camera_smooth)
	GlobalCameraScript.move_camera_jump.connect(_move_camera_jump)
	GlobalCameraScript.change_current_camera.connect(_change_current_camera)
	GlobalCameraScript.camera_on_player.connect(_change_camera_state)
	GlobalCameraScript.bind_camera_LR.connect(_bind_camera_LR)
	GlobalCameraScript.remove_camera_bounds_LR.connect(_unbind_camera_LR)
	GlobalCameraScript.bind_camera_y.connect(_bind_camera_y)
	GlobalCameraScript.remove_camera_bounds_y.connect(_unbind_camera_y)


func _physics_process(delta: float) -> void:
	# make camera follow player
	if camera_on_player:
		camera_speed = PLAYER_CAMERA_FOLLOW_SPEED
		camera_location_node = $Player/PlayerCameraLocation
	
	# restrict x values of camera
	if camera_bound_LR:
		var distance_to_left_bound: Vector3 = Vector3(camera_left_bound.distance_to(camera_location_node.global_position), 0, 0)
		var distance_to_right_bound: Vector3 = Vector3(camera_right_bound.distance_to(camera_location_node.global_position), 0, 0)
		if distance_to_left_bound.x < 0:
			camera_location_node.global_position -= camera_parent_basis * distance_to_left_bound
		elif distance_to_right_bound.x < 0:
			camera_location_node.global_position += camera_parent_basis * distance_to_right_bound
	
	# restrict y values of camera
	if camera_bound_y:
		if camera_location_node.global_position.y < camera_lower_bound_y:
			camera_location_node.global_position.y = camera_lower_bound_y
		elif camera_location_node.global_position.y > camera_upper_bound_y:
			camera_location_node.global_position.y = camera_upper_bound_y
	
	# camera either moves smoothly or jumps to the next position
	if camera_smooth:
		main_camera.global_transform = main_camera.global_transform.interpolate_with(camera_location_node.global_transform, delta * camera_speed)
	else:
		main_camera.global_position = camera_location


func _move_camera_smooth(new_location_node: Node3D) -> void:
	camera_smooth = true
	camera_speed = CAMERA_TRANSITION_SPEED
	camera_location_node = new_location_node
	camera_location = camera_location_node.global_position


func _move_camera_jump(new_location_node: Node3D) -> void:
	camera_smooth = false
	camera_location_node = new_location_node
	camera_location = camera_location_node.global_position


func _change_current_camera(new_camera: Camera3D) -> void:
	new_camera.make_current()


func _change_camera_state(tf: bool) -> void:
	camera_on_player = tf


func _bind_camera_LR(left: Plane, right: Plane, room_basis: Basis) -> void:
	camera_left_bound = left
	camera_right_bound = right
	camera_parent_basis = room_basis
	camera_bound_LR = true


func _unbind_camera_LR() -> void:
	camera_bound_LR = false


func _bind_camera_y(lower: float, upper: float) -> void:
	camera_lower_bound_y = lower
	camera_upper_bound_y = upper
	camera_bound_y = true


func _unbind_camera_y() -> void:
	camera_bound_y = false
