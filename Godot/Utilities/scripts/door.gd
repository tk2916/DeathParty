extends Node3D

signal enter_door()
signal return_through_door()

var back_room_z : float = -3.0
var main_room_z : float = 1.0
var currentMaterial : BaseMaterial3D
var player_at_door : bool
var player_distance_to_door : float

@onready var door_model : Node3D = $DoorModel
@onready var forward_plane : Plane = Plane(basis.z, global_position)
@onready var door_opening_speed : float = 5
@onready var original_rotation : float = door_model.rotation.y

func _ready() -> void:
	GlobalPlayerScript.player_moved.connect(_change_door_visibility)
	
	var door_mesh : MeshInstance3D = $DoorModel/DoorMesh
	currentMaterial = door_mesh.get_active_material(0).duplicate()
	door_mesh.set_surface_override_material(0, currentMaterial)


func _physics_process(delta: float) -> void:
	if not player_at_door:
		open_door(delta, original_rotation)
	else:
		open_door(delta, PI/2 * player_distance_to_door)


func open_door(delta: float, to: float) -> void:
	door_model.rotation.y = lerp_angle(door_model.rotation.y, to, door_opening_speed * delta)


func _change_door_visibility(pos: Vector3) -> void:
	if forward_plane.distance_to(pos) > 0:
		currentMaterial.albedo_color.a = 1
	else:
		currentMaterial.albedo_color.a = 0.2


func calculate_player_distance(pos: Vector3) -> void:
	if forward_plane.distance_to(pos) > 0:
		player_distance_to_door = 1
	else:
		player_distance_to_door = -1


func _on_entrance_area_body_entered(body: Node3D) -> void:
	calculate_player_distance(body.global_position)
	player_at_door = true


func _on_entrance_area_body_exited(body: Node3D) -> void:
	player_at_door = false

#func _on_entrance_detector_player_interacted(body: CharacterBody3D) -> void:
	#body.global_position = $ExitLocation.global_position
	#currentMaterial.albedo_color.a = 0.2
	#enter_door.emit()
	#$DoorSound.play()
#
#
#func _on_exit_detector_player_interacted(body: CharacterBody3D) -> void:
	#body.global_position = $EntranceLocation.global_position
	#currentMaterial.albedo_color.a = 1
	#return_through_door.emit()
	#$DoorSound.play()
