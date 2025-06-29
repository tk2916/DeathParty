## This script should be extended by a Room scene which has a CollisionShape3D child named "RoomArea"
## the extended script should connect to RoomArea's _on_body entered and exited signals

extends Area3D

# offsets must be changed MANUALLY if the MainCamera's default position or fov change
# offset's x value is the desired distance from the edges of the area
var camera_LR_offset: Vector3 = Vector3(3.8, 0, 0)
var camera_y_offset: float
var left_bound: Plane
var right_bound: Plane
var lower_bound: float
var upper_bound: float
var inner_bound: Plane
var outer_bound: Plane
var room_area_shape: BoxShape3D


func _ready() -> void:
	var room_area: CollisionShape3D = $RoomArea
	## Left and Right bounds
	room_area_shape = room_area.shape
	# [.....|.....] <= $RoomArea.shape.size.x ( '|' is halfway point)
	# [.....|       <= $RoomArea.shape.size.x/2
	# [.x...|       <= $RoomArea.shape.size.x/2 - camera_LR_offset
	#   x...|       <= Where the camera is limited to go
	camera_LR_offset = abs((room_area_shape.size/2 - camera_LR_offset) * basis)
	var left_point: Vector3 = (global_position) + (camera_LR_offset * -basis.x)
	var right_point: Vector3 = (global_position) + (camera_LR_offset * basis.x)
	
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
	var y_center: float = room_area_shape.size.y/2 + global_position.y
	lower_bound = y_center - camera_y_offset
	upper_bound = y_center + camera_y_offset
	
	
	## Depth Bounds
	# By default, camera stays 9m away
	var default_depth: Vector3 = global_position + ((room_area_shape.size.z/2 + 9) * basis.z)
	inner_bound = Plane(basis.z, default_depth)
	outer_bound = Plane(-basis.z, default_depth)

func move_to_foreground(body: Node3D) -> Vector3:
	var initial_position: Vector3 = body.global_position
	initial_position *= abs((basis.x + basis.y))
	var new_position: Vector3 = initial_position
	new_position += global_position * basis.z
	
	return new_position

## These functions should be defined in the extended script
#func _on_body_entered(_body: Node3D) -> void:
	#GlobalCameraScript.bind_camera_LR.emit(left_bound, right_bound, basis)
	#GlobalCameraScript.bind_camera_y.emit(lower_bound, upper_bound)
	#body.transform.basis = body.transform.basis.looking_at(-basis.z)

#func _on_body_exited(_body: Node3D) -> void:
	#GlobalCameraScript.remove_camera_bounds_x.emit()
