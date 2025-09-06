class_name FootstepSounds extends FmodEventEmitter3D
## an FmodEventEmitter3D that can be attached to CharacterBody3Ds to make them play footstep sounds
##
## handles tracking the speed to only play footsteps while moving, raycasting to get the surface
## the character is stepping on, and playing the corresponding sounds.
## use by calling this class's play_footstep_sound() function from an AnimationPlayer on the frame
## where the character's foot touches the ground

@onready var ray_cast: RayCast3D = %RayCast3D

var previous_position: Vector3 = global_position
var speed: Vector3
const FOOTSTEP_COOLDOWN := 0.3
var time_since_last_step := 0.0


# track position across physics frames to see if character is moving
func _physics_process(delta: float) -> void:
	speed = global_position - previous_position
	previous_position = global_position
	time_since_last_step += delta


# this func should be called from character animations
# on the frame their feet touch the ground
func play_footstep_sound() -> void:
	# use the raycast to get the surface the character is standing on
	#print("RAYCASTING . . .")
	var surface: Node3D = ray_cast.get_collider()
	#print("surface: ", surface)

	var surface_groups: Array

	# get all the groups the surface node is in
	if surface:
		surface_groups = surface.get_groups()
		#print("surface groups: ", surface_groups)

	var surface_material: String

	# if the surface is in a group starting with "material_",
	# store the name of the material
	for group: String in surface_groups:
		if group.begins_with("material"):
			surface_material = group.trim_prefix("material_")
			#print("surface material: ", surface_material)
			break

	# set the fmod land texture parameter based on the surface material
	if surface_material:
		set_parameter("LandTexture", surface_material)

	# play a step sound if the character is moving
	if speed != Vector3.ZERO and time_since_last_step > FOOTSTEP_COOLDOWN:
		play()
		time_since_last_step = 0.0
