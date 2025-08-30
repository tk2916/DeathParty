extends CanvasLayer


@export var exterior_scene_loader: SceneLoader
@export var door: Node3D

@onready var move_controls_popup: PanelContainer = %MoveControlsPopup
@onready var phone_controls_popup: PanelContainer = %PhoneControlsPopup
@onready var journal_controls_popup: PanelContainer = %JournalControlsPopup

var player: Player

enum States {
	INTRO, WALK, UNLOCK_PHONE, USING_PHONE,
	OPEN_JOURNAL, USING_JOURNAL, TUTORIAL_FINISHED
	}

var state: States:
	set(new_state):
		state = new_state
		if player == null:
			player = get_tree().get_first_node_in_group("player")
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
			States.USING_PHONE:
				print("TUTORIAL STEP: USING PHONE")
				phone_controls_popup.hide()
			States.OPEN_JOURNAL:
				print("TUTORIAL STEP: OPEN JOURNAL")
				journal_controls_popup.show()
			States.USING_JOURNAL:
				print("TUTORIAL STEP: USING JOURNAL")
			States.TUTORIAL_FINISHED:
				print("TUTORIAL STEP: FINISHED")
				exterior_scene_loader.monitoring = true
				door.show()
				queue_free()

var move_controls_popup_fade_timer_started := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await ContentLoader.finished_loading
	$LoadingTimer.start()
	await $LoadingTimer.timeout
	player = get_tree().get_first_node_in_group("player")
	player.movement_disabled = true
	state = States.INTRO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		States.WALK:
			if player.player_velocity != Vector3.ZERO and not move_controls_popup_fade_timer_started:
				$MoveControlsPopupFadeTimer.start()
				move_controls_popup_fade_timer_started = true
		States.UNLOCK_PHONE:
			if get_tree().get_first_node_in_group("phone").visible == true:
				state += 1
		States.USING_PHONE:
			if get_tree().get_first_node_in_group("phone").visible == false:
				state += 1
		States.OPEN_JOURNAL:
			if get_tree().get_first_node_in_group("journal") != null:
				state += 1
		States.USING_JOURNAL:
			if get_tree().get_first_node_in_group("journal") == null:
				state += 1


func _on_bedroom_intro_finished() -> void:
	state += 1


func _on_move_control_popup_fade_timer_timeout() -> void:
	state += 1
