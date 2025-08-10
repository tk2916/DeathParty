extends CanvasLayer


@export var player: CharacterBody3D

var player_added_speed := 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		player.player_speed += player_added_speed
	elif not toggled_on:
		player.player_speed -= player_added_speed
