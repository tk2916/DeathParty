class_name FootstepSounds extends FmodEventEmitter3D


@onready var ray_cast: RayCast3D = %RayCast3D

var previous_position: Vector3 = global_position
var speed: Vector3


func _physics_process(_delta: float) -> void:
	speed = global_position - previous_position
	previous_position = global_position


func play_footstep_sound() -> void:
	var surface: Node3D = ray_cast.get_collider()
	var surface_groups: Array
	
	if surface:
		print("surface: ", surface)
		surface_groups = surface.get_groups()
		print("surface groups: ", surface_groups)
	
	var surface_material: String

	for group in surface_groups:
		if group.begins_with("material"):
			surface_material = group.trim_prefix("material_")
			print("surface material: ", surface_material)
			break

	if surface_material:
		set_parameter("LandTexture", surface_material)

	if speed != Vector3.ZERO:
		play()
