class_name TeleportPoint extends MeshInstance3D

@export var spawn_point_number : Globals.SPAWN_OPTIONS = 0
@onready var teleport_pos : Vector3 = global_position

func _ready() -> void:
	visible = false
