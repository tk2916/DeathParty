extends NPCAgent

var movement_speed: float = 1.9

func _ready() -> void:
	wait()

func _physics_process(delta: float) -> void:
	wander(movement_speed, 1, delta)

func wait() -> void:
	await get_tree().physics_frame
