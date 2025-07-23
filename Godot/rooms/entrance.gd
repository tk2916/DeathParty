extends "res://Utilities/scripts/define_camera_bounds.gd"

func _ready() -> void:
	super()
	GlobalPlayerScript.player_moved.connect(hide_entrance)

func _on_body_entered(body: Node3D) -> void:
	GlobalCameraScript.remove_all_bounds()
	GlobalCameraScript.camera_on_player.emit(true)
	GlobalCameraScript.bind_camera_LR.emit(left_bound, right_bound, basis)

func hide_entrance(pos: Vector3) -> void:
	if(background_plane.distance_to(pos) < 0):
		visible = false
	else:
		visible = true
