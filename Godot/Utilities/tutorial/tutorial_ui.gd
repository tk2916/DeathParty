extends CanvasLayer


@onready var move_controls_popup: PanelContainer = %MoveControlsPopup
@onready var phone_controls_popup: PanelContainer = %PhoneControlsPopup

var player: Player

enum States {INTRO, WALK, UNLOCK_PHONE, OPEN_TEXTS}

var state: States:
	set(new_state):
		state = new_state
		match new_state:
			States.INTRO:
				print("TUTORIAL STEP: INTRO")
			States.WALK:
				print("TUTORIAL STEP: WALK")
				player.movement_disabled = false
				move_controls_popup.show()
			States.UNLOCK_PHONE:
				print("TUTORIAL STEP: UNLOCK PHONE")
				move_controls_popup.hide()
				phone_controls_popup.show()
			States.OPEN_TEXTS:
				phone_controls_popup.hide()

var player_prev_pos: Vector3

var move_controls_popup_fade_timer_started := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ContentLoader.finished_loading.connect(on_finished_loading)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		States.WALK:
			if player.player_velocity != Vector3.ZERO and not move_controls_popup_fade_timer_started:
				$MoveControlsPopupFadeTimer.start()
				move_controls_popup_fade_timer_started = true
		States.UNLOCK_PHONE:
			if Input.is_action_just_pressed("toggle_phone"):
				state += 1


func on_finished_loading() -> void:
	$LoadingTimer.start()
	await $LoadingTimer.timeout
	player = get_tree().get_first_node_in_group("player")
	player.movement_disabled = true
	state = States.INTRO


func _on_bedroom_intro_finished() -> void:
	state += 1


func _on_move_control_popup_fade_timer_timeout() -> void:
	print("MOVE CONTROLS POPUP FADE TIMER ENDED")
	state += 1
