extends "res://Utilities/scripts/define_camera_bounds.gd"

@export var room_area : CollisionShape3D
@export var things_to_hide : Node3D

@onready var room_shape : BoxShape3D = room_area.shape
@onready var background_plane := Plane(basis.z, (global_position - (room_shape.size/2 * basis)))

func _ready() -> void:
	## TODO: figure out why this script messes with the camera bounds
	super()
	GlobalPlayerScript.player_moved.connect(_change_visibility)


func _on_body_entered(body: Node3D) -> void:
	# Define camera bounds 
	GlobalCameraScript.bind_camera_LR.emit(left_bound, right_bound, basis)
	GlobalCameraScript.bind_camera_y.emit(lower_bound, upper_bound)
	body.transform.basis = Basis.looking_at(-basis.z)
	
	FmodServer.set_global_parameter_by_name_with_label("room", "front room")


func _change_visibility(pos: Vector3) -> void:
	if(background_plane.distance_to(pos) < 0):
		things_to_hide.visible = false
	else:
		things_to_hide.visible = true
