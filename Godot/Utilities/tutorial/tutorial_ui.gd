# this script handles the pop-ups at the start of the game which tell the player
# the controls etc.

# it also handles locking movement during the title screen, then showing the door
# and enabling the scene loader for exiting the room once the tutorial is over

# NOTE: tutorial_ui is probably a bad name for it because of that other non-ui
#		stuff it does sorry lol

# TODO: maybe change this scripts name to tutorial_manager or something

extends CanvasLayer


@export var exterior_scene_loader: SceneLoader
@export var door: Node3D

@onready var loading_timer: Timer = %LoadingTimer
@onready var move_controls_popup: PanelContainer = %MoveControlsPopup
@onready var walk_complete_timer: Timer = %WalkCompleteTimer
@onready var phone_controls_popup: PanelContainer = %PhoneControlsPopup
@onready var journal_controls_popup: PanelContainer = %JournalControlsPopup

var player: Player

enum States {
	INTRO, WALK, WALK_COMPLETE, UNLOCK_PHONE, USING_PHONE,
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
			States.WALK_COMPLETE:
				print("TUTORIAL STEP: WALK COMPLETE")
				walk_complete_timer.start()
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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# NOTE: we wait for the content loader to give the finished_loading signal
	#		before referencing the player because the inital loading involves
	#		unloading this scene which will break the reference and cause errors
	#		(i think)

	#		the additional $LoadingTimer is here because of a quirk with the
	#		timing of that finished_loading signal, which i think is emitted before
	#		the whole tree is ready (or something lol) - very bad to just have
	#		a timer in here probably because that will cause crashes on slow pcs
	#		so:

	# TODO: adjust the timing of this finished_loading signal in content_loader.gd
	#		or make a new, safer signal to use instead
	#		so we can remove this hardcoded timer :p
	await ContentLoader.finished_loading
	loading_timer.start()
	await loading_timer.timeout
	player = get_tree().get_first_node_in_group("player")
	player.movement_disabled = true
	state = States.INTRO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		States.WALK:
			if player.player_velocity != Vector3.ZERO:
				state += 1
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


func _on_walk_complete_timer_timeout() -> void:
	state += 1
