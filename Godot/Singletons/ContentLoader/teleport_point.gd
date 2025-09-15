class_name TeleportPoint extends MeshInstance3D

@export var spawn_point_number : Globals.SPAWN_OPTIONS = Globals.SPAWN_OPTIONS.ONE
@onready var teleport_pos : Vector3 = global_position

func _ready() -> void:
	visible = false
