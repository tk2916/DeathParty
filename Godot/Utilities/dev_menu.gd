extends CanvasLayer


@export var player: Player

@onready var player_speed_button: Button = %PlayerSpeedButton

var player_added_speed := 10.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_dev_menu"):
		toggle_menu()


func toggle_menu() -> void:
	visible = !visible


func _on_player_speed_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		player.player_speed += player_added_speed
		player_speed_button.text = "reset player speed"
	elif not toggled_on:
		player.player_speed -= player_added_speed
		player_speed_button.text = "increase player speed"
