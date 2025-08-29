extends CanvasLayer


@onready var player = get_tree().get_root().get_node("Main/Player")

enum States {INTRO, WALK, UNLOCK_PHONE}

var state: States:
	set(new_state):
		var previous_state := state
		state = new_state

		match state:
			States.INTRO:
				print("TUTORIAL STEP: INTRO")

			States.WALK:
				print("TUTORIAL STEP: WALK")

			States.UNLOCK_PHONE:
				print("TUTORIAL STEP: UNLOCK PHONE")

var player_prev_pos: Vector3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = States.INTRO
	
	var players = get_tree().get_nodes_in_group("player")
	print(players)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		States.WALK:
			pass
			var player_current_pos: Vector3 = player.global_position
			if player_current_pos != player_prev_pos:
				state += 1
			player_prev_pos = player_current_pos


func _on_bedroom_intro_finished() -> void:
	state += 1
