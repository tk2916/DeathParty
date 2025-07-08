## Emits a signal when the player is within the area and presses interact
## To use, make an InteractionDetector instance a child of the node that the user interacts with
## then manually create a collision object as a child of the created instance
extends Area3D

signal player_interacted(body: CharacterBody3D)
signal player_in_range(tf : bool)

var player_currently_in_range : bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_currently_in_range:
		player_interacted.emit(get_overlapping_bodies()[0])
	
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_currently_in_range = true
		player_in_range.emit(true)

func _on_body_exited(body : Node3D) -> void:
	if body.is_in_group("player"):
		print("Player exited")
		player_currently_in_range = false
		player_in_range.emit(false)
