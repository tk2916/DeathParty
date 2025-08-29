extends CanvasLayer


@onready var player: Player = get_tree().get_first_node_in_group("player")

enum States {INTRO, WALK, UNLOCK_PHONE}

var state: States:
	set(new_state):
		state = new_state

		match state:
			States.INTRO:
				print("TUTORIAL STEP: INTRO")
				player.movement_disabled = true

			States.WALK:
				print("TUTORIAL STEP: WALK")
				player.movement_disabled = false

			States.UNLOCK_PHONE:
				print("TUTORIAL STEP: UNLOCK PHONE")

var player_prev_pos: Vector3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = States.INTRO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		States.WALK:
			var player_current_pos: Vector3 = player.global_position
			if player_current_pos != player_prev_pos:
				state += 1
			player_prev_pos = player_current_pos


func _on_bedroom_intro_finished() -> void:
	print("INTRO FINISHED SIGNAL RECEIVED")
	state += 1
