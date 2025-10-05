@tool
extends Node3D


@export var x_offset: float = -1.15
@export var y_offset: float = 2

@onready var parent_npc: NPC = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	# since rotating the npc will affect the global position of this popup,
	# we reset it every frame based on the current global pos of the npc to
	# keep its position consistent
	if parent_npc:
		global_position = parent_npc.global_position + Vector3(x_offset, y_offset, 0)
