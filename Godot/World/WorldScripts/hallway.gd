extends "res://Utilities/scripts/define_camera_bounds.gd"

@export var room_area: CollisionShape3D
@export var path_follow_node: PathFollow3D

func _ready() -> void:
	super()
	GlobalPlayerScript.player_moved.connect(_calculate_progress_ratio)

func _on_body_entered(body: Node3D) -> void:
	# Define camera bounds 
	#GlobalCameraScript.bind_camera_LR.emit(left_bound, right_bound, basis)
	#GlobalCameraScript.bind_camera_y.emit(lower_bound, upper_bound)
	GlobalCameraScript.remove_camera_bounds_LR.emit()
	GlobalCameraScript.remove_camera_bounds_y.emit()
	GlobalCameraScript.remove_camera_bounds_depth.emit()
	GlobalCameraScript.camera_on_player.emit(false)
	
	GlobalCameraScript.bind_camera_path.emit(path_follow_node)
	
	body.transform.basis = Basis.looking_at(basis.z, basis.y, true)
	# teleport player into foreground
	body.global_position = move_to_foreground(body)

func _calculate_progress_ratio(pos: Vector3) -> void:
	# calculate center, left, and rightmost points of the room's area
	var center: float = compress_vector3(position * basis.x)
	var leftmost_value: float = center - (room_area.shape.size.x/2)
	var rightmost_value: float = center + (room_area.shape.size.x/2)
	
	var player_LR_value: float = compress_vector3(pos * basis.x)
	
	var player_progress_ratio = (player_LR_value-leftmost_value) / (rightmost_value - leftmost_value)
	
	path_follow_node.progress_ratio = player_progress_ratio
	
	if has_overlapping_bodies():
		var player_body: Node3D = get_overlapping_bodies().front()
		path_follow_node.look_at(player_body.position + Vector3(0,1.2,0))

## @param vec - Vector3, assumes that one coordinate has a value and the others are zero
func compress_vector3(vec: Vector3) -> float:
	return vec.x + vec.y + vec.z
