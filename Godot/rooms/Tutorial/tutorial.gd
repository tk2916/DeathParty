extends Node3D

@onready var main: Node = preload("res://main.tscn").instantiate()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file("res://main.tscn")
		ContentLoader.reset()
