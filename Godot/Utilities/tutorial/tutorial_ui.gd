extends CanvasLayer


var player: Player

enum States {INTRO, WALK, UNLOCK_PHONE}

var state: States:
	set(new_state):
		match new_state:
			States.INTRO:
				print("TUTORIAL STEP: INTRO")
			States.WALK:
				print("TUTORIAL STEP: WALK")
				player.movement_disabled = false
			States.UNLOCK_PHONE:
				print("TUTORIAL STEP: UNLOCK PHONE")

var player_prev_pos: Vector3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ContentLoader.finished_loading.connect(on_finished_loading)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		States.WALK:
			var player_current_pos: Vector3 = player.global_position
			if player_current_pos != player_prev_pos:
				state += 1
			player_prev_pos = player_current_pos


func on_finished_loading() -> void:
	$LoadingTimer.start()
	await $LoadingTimer.timeout
	player = get_tree().get_first_node_in_group("player")
	player.movement_disabled = true
	state = States.INTRO


func _on_bedroom_intro_finished() -> void:
	state += 1
