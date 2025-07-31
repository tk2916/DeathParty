extends Room3D

@export var things_to_hide : Node3D


func _ready() -> void:
	super()
	body_entered.connect(handle_player_entrance)


func handle_player_entrance(body: Node3D) -> void:
	remove_all_bounds(body)
	rotate_player(body)
	
	keep_camera_on_player(body)
	bind_camera_LR(body)
	bind_camera_y(body)
	FmodServer.set_global_parameter_by_name_with_label("room", "upstairs room")


func _on_door_enter_door() -> void:
	things_to_hide.visible = false


func _on_door_return_through_door() -> void:
	things_to_hide.visible = true
