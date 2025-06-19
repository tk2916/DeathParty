## Emits a signal when the player is within the area and presses interact
## To use, make an InteractionDetector instance a child of the node that the user interacts with
## then manually create a collision object as a child of the created instance
extends Area3D

signal player_interacted(body: CharacterBody3D)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and has_overlapping_bodies():
		player_interacted.emit(get_overlapping_bodies()[0])
	
