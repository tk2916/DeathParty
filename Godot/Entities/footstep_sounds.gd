extends FmodEventEmitter3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_footstep_sound() -> void:
	# (this is called by the AnimationPlayer on the
	# frames where the boots touch the ground)
	
	# check if player is holding a move input and play a footstep if they are
	# this can probably be handled better by moving around the
	# direction vars and just checking those instead
	
	# (we have to check for movement because otherwise the animation blending
	# causes footsteps to keep playing as the player stops moving and the walk
	# anim fades into the idle one)
	for action in InputMap.get_actions():
		if action.begins_with("move_") and Input.is_action_pressed(action):
			play()
