## Handles signals that tell the camera where to go
extends Node

@warning_ignore_start("unused_signal")
# Signals for moving the camera to a new position
# new_camera_position: Vector3 of the desired position
#    two signals are provided in case both smooth and instant camera movement is desired
signal move_camera_smooth(new_camera_position_node: Node3D)
signal move_camera_jump(new_camera_position_node: Node3D)

# Signal for defining a new camera to be set as the current camera
signal change_current_camera(new_camera: Camera3D)

# Signal for saying the camera should or shouldn't be on the player
signal camera_on_player(tf: bool)

# Signal for binding the camera to a Path3D
signal bind_camera_path(follow_node: PathFollow3D)

# Signals for keeping the camera within a room's boundaries
# left_bound: global_position.x value that the camera's global_position.x cannot GO UNDER
# right_bound: global_position.x value that the camera's global_position.x cannot EXCEED
# room_basis: the basis of the given room
signal bind_camera_LR(left_bound: Plane, right_bound: Plane, room_basis: Basis)

# lower_bound: global_position.y value that the camera's global_position.y cannot GO UNDER
# upper_bound: global_position.y value that the camera's global_position.y cannot EXCEED
signal bind_camera_y(lower_bound: float, upper_bound: float)

# inner_bound: plane defining how far the camera can move in the rotated -z direction
# outer_bound: plane defining how far the camera can move in the rotated +z direction
signal bind_camera_depth(inner_bound: Plane, outer_bound: Plane, room_basis: Basis)

# Signal when left and right bounds are no longer needed
signal remove_camera_bounds_LR()

# Signal when lower and upper bounds are no longer needed
signal remove_camera_bounds_y()

# Signal when inner and outer bounds are no longer needed
signal remove_camera_bounds_depth()

# Signal when path bounds are no longer needed
signal remove_camera_bounds_path()
@warning_ignore_restore("unused_signal")
