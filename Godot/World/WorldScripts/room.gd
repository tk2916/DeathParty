extends "res://Utilities/scripts/define_camera_bounds.gd"
@onready var room_area : CollisionShape3D = $RoomArea
@onready var room_shape : BoxShape3D = room_area.shape
@onready var background_plane : Plane = Plane(basis.z, (global_position - (room_shape.size/2 * basis)))

func _ready() -> void:
	## TODO: figure out why this script messes with the camera bounds
	super()
	GlobalPlayerScript.player_moved.connect(_change_visibility)
	pass


func _on_body_entered(body: Node3D) -> void:
	# Define camera bounds 
	GlobalCameraScript.bind_camera_LR.emit(left_bound, right_bound, basis)
	GlobalCameraScript.bind_camera_y.emit(lower_bound, upper_bound)
	body.transform.basis = Basis.looking_at(-basis.z)
	
	FmodServer.set_global_parameter_by_name_with_label("room", "front room")


func _change_visibility(pos: Vector3) -> void:
	if(background_plane.distance_to(pos) < 0):
		$ThingsToHide.visible = false
	else:
		$ThingsToHide.visible = true
