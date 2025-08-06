class_name FootstepSounds extends FmodEventEmitter3D


var previous_position: Vector3 = global_position
var speed: Vector3


func _physics_process(_delta: float) -> void:
	speed = global_position - previous_position
	previous_position = global_position


func play_footstep_sound() -> void:
	if speed != Vector3.ZERO:
		play()
