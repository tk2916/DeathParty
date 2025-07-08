extends Interactable

var outline : Node3D

func _ready() -> void:
	$InteractionDetector.player_interacted.connect(when_interacted)
	outline = get_node_or_null("Outline")
	if outline:
		outline.visible = false

func when_interacted(_body : Node3D) -> void:
	print("interacted")
