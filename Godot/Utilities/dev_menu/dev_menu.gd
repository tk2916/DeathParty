extends CanvasLayer


@export var player: Player
@export var party_room_music: FmodEventEmitter3D
@export var game_ui: Control

@onready var player_speed_button: Button = %PlayerSpeedButton
@onready var slow_motion_button: Button = %SlowMotionButton

@onready var teleport_button_container: GridContainer = %TeleportButtonContainer
@export var teleport_button_scene: PackedScene

var player_added_speed := 10.0

# var for tracking the current scene (was made to avoid a crash when trying
# to tp to the current room, but commented it out because it could only track
# the scene changing thru tping in the menu (and not thru the player moving
# between rooms normally) which would probably end up being more confusing
# than crashing lol
#var current_room: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get a list of all the rooms
	var rooms: Array = get_tree().get_nodes_in_group("loadable_scene")

	# add a button for teleporting to each room to the dev menu
	for room: Node3D in rooms:
		var teleport_button: Button = teleport_button_scene.instantiate()

		teleport_button.text = room.name
		teleport_button.pressed.connect(func() -> void: teleport_player(teleport_button.text))

		teleport_button_container.add_child(teleport_button)

		#current_room = ContentLoader.og_scene


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_dev_menu"):
		toggle_menu()


func toggle_menu() -> void:
	visible = !visible


func _on_reset_player_button_pressed() -> void:
	player.reset_position()


func _on_player_speed_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		player.player_speed += player_added_speed
		player_speed_button.text = "reset player speed"
	elif not toggled_on:
		player.player_speed -= player_added_speed
		player_speed_button.text = "increase player speed"


func _on_slow_motion_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Engine.time_scale = 0.25
		slow_motion_button.text = "reset game speed"
	elif not toggled_on:
		Engine.time_scale = 1.0
		slow_motion_button.text = "slow motion"


func _on_skip_music_button_pressed() -> void:
	party_room_music.play()


func teleport_player(room: String) -> void:
	#if room != current_room:
	ContentLoader.direct_teleport_player(room)
	#current_room = room
