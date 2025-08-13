## An Area3D with built-in methods used for controlling the main camera
extends Area3D
class_name Room3D

@export var room_area: CollisionShape3D
@export var path_follow_node: PathFollow3D

# offsets must be changd MANUALLY if the MainCamera's default position or fov change
# offset's x value is the desired distance from the edges of the area
var camera_LR_offset: Vector3 = Vector3(3.8, 0, 0)
var camera_y_offset: float
var left_bound: Plane
var right_bound: Plane
var lower_bound: float
var upper_bound: float
var inner_bound: Plane
var outer_bound: Plane
var room_area_center: Vector3
var room_area_shape: BoxShape3D
var background_plane: Plane
var default_depth: Vector3


# connect the signal to set the fmod parameter for the current room
# when the player enters
func _enter_tree() -> void:
	body_entered.connect(func(body): set_fmod_room_parameter(body, self.name))


func _ready() -> void:
	assert(room_area, "Room area not defined! Go to this room's properties in the Inspector and assign a CollisionShape3D containing the room to the Room Area property")
	call_deferred("calculate_bounds")


func calculate_bounds() -> void:
	# Calling await in _ready is bad practice, I think
	await get_tree().process_frame # Wait a frame before calculating center - required if scene is loaded at runtime
	room_area_center = room_area.global_transform.origin
	room_area_shape = room_area.shape
	background_plane = Plane(room_area.basis.z, (room_area_center - (room_area.shape.size/2 * basis)))
	default_depth = room_area_center + ((room_area_shape.size.z/2 + 9) * basis.z)
	
	## Left and Right bounds
	# [.....|.....] <= $RoomArea.shape.size.x ( '|' is halfway point)
	# [.....|       <= $RoomArea.shape.size.x/2
	# [.x...|       <= $RoomArea.shape.size.x/2 - camera_LR_offset
	#   x...|       <= Where the camera is limited to go
	camera_LR_offset = abs((room_area_shape.size/2 - camera_LR_offset) * basis)
	var left_point: Vector3 = (room_area_center) + (camera_LR_offset * -basis.x)
	var right_point: Vector3 = (room_area_center) + (camera_LR_offset * basis.x)
	
	# If left bound and right bound go past each other (in the case of small rooms),
	# center the camera on the room instead
	#if(left_point*basis.x > right_point*basis.x):
		#left_point = (left_point + right_point)/2
		#right_point = left_point
	
	left_bound = Plane(basis.x, left_point)
	right_bound = Plane(-basis.x, right_point)
	
	
	## Y bounds
	# For now, just keep the camera in the center
	camera_y_offset = room_area_shape.size.y/2
	
	camera_y_offset = room_area_shape.size.y/2 - camera_y_offset
	var y_center: float = room_area_center.y
	lower_bound = y_center - camera_y_offset
	upper_bound = y_center + camera_y_offset
	
	
	## Depth Bounds
	# By default, camera stays 9m away
	inner_bound = Plane(basis.z, default_depth)
	outer_bound = Plane(-basis.z, default_depth)


func move_player_to_foreground(body: Node3D) -> void:
	var initial_position: Vector3 = body.global_position
	initial_position *= abs((basis.x + basis.y))
	var new_position: Vector3 = initial_position
	## If moving to foreground doesn't work, try changing global_position to room_area_center!
	new_position += global_position * basis.z
	
	body.global_position = new_position


func rotate_player(body: Node3D) -> void:
	body.transform.basis = Basis.looking_at(basis.z, basis.y, true)


## Functions used for following paths
func _calculate_progress_ratio(pos: Vector3) -> void:
	if not path_follow_node:
		return
	# calculate center, left, and rightmost points of the room's area
	var center: float = compress_vector3(position * basis.x)
	var leftmost_value: float = center - (room_area.shape.size.x/2)
	var rightmost_value: float = center + (room_area.shape.size.x/2)
	
	var player_LR_value: float = compress_vector3(pos * basis.x)
	
	var player_progress_ratio: float = (player_LR_value-leftmost_value) / (rightmost_value - leftmost_value)
	
	path_follow_node.progress_ratio = player_progress_ratio
	
	if has_overlapping_bodies():
		var player_body: Node3D = get_overlapping_bodies().front()
		#path_follow_node.look_at(player_body.position + Vector3(0,1.2,0)) # Look at player
		var look_straight: Vector3 = Vector3(player_body.position.x, path_follow_node.position.y, player_body.position.z)
		path_follow_node.look_at(look_straight) # Look straight ahead

## @param vec - Vector3, assumes that one coordinate has a value and the others are zero
func compress_vector3(vec: Vector3) -> float:
	return vec.x + vec.y + vec.z


## Functions for emitting GlobalCameraScript signals
func remove_all_bounds(body: Node3D) -> void:
	GlobalCameraScript.camera_on_player.emit(false)
	GlobalCameraScript.remove_camera_bounds_LR.emit()
	GlobalCameraScript.remove_camera_bounds_y.emit()
	GlobalCameraScript.remove_camera_bounds_depth.emit()
	GlobalCameraScript.remove_camera_bounds_path.emit()

func bind_camera_LR(body: Node3D) -> void:
	GlobalCameraScript.bind_camera_LR.emit(left_bound, right_bound, basis)


func bind_camera_y(body: Node3D) -> void:
	GlobalCameraScript.bind_camera_y.emit(lower_bound, upper_bound)


func bind_camera_depth(body: Node3D) -> void:
	GlobalCameraScript.bind_camera_depth.emit(inner_bound, outer_bound, basis)


func bind_camera_path(body: Node3D) -> void:
	assert(path_follow_node, "path_follow_node is not defined! Assign it a value in this node's exports")
	GlobalCameraScript.bind_camera_path.emit(path_follow_node)


func keep_camera_on_player(body: Node3D) -> void:
	GlobalCameraScript.camera_on_player.emit(true)


func keep_camera_off_player(body: Node3D) -> void:
	GlobalCameraScript.camera_on_player.emit(false)


func set_fmod_room_parameter(body: Node3D, room_name: String):
	#print("SETTING FMOD ROOM TO: ", room_name)
	if body.is_in_group("player"):
		FmodServer.set_global_parameter_by_name_with_label("Room", room_name)
	#print("FMOD ROOM IS NOW: ", FmodServer.get_global_parameter_by_name("Room"))


## These functions should be defined in the extended script
#func _on_body_entered(_body: Node3D) -> void:
	#GlobalCameraScript.bind_camera_LR.emit(left_bound, right_bound, basis)
	#GlobalCameraScript.bind_camera_y.emit(lower_bound, upper_bound)
	#body.transform.basis = body.transform.basis.looking_at(-basis.z)

#func _on_body_exited(_body: Node3D) -> void:
	#GlobalCameraScript.remove_camera_bounds_x.emit()
