class_name FootstepSounds extends FmodEventEmitter3D


var previous_position: Vector3 = global_position


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	previous_position = global_position


func play_footstep_sound() -> void:
	if global_position != position:
		play()
