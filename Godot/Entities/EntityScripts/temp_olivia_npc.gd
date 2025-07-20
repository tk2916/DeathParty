extends NPCAgent

@export var path: Path3D

var movement_speed: float = 1.9

func _ready() -> void:
	wait()

func _physics_process(delta: float) -> void:
	wander(movement_speed, 1, delta)
	#move_between_nodes_random(path, movement_speed, 1)
func wait() -> void:
	await get_tree().physics_frame
