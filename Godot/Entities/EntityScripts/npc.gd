extends StaticBody3D

func _ready() -> void:
	$InteractionDetector.player_interacted.connect(when_interacted)


func when_interacted(_body : Node3D) -> void:
	print("interacted")
