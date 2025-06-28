extends StaticBody3D

@export var button : Button
@export var sub_viewport : Viewport
@onready var original_position : Vector3 = global_position
@onready var up_direction : Vector3 = transform.basis.y.normalized()

@export var flip_to_page : int

func return_to_original_pos():
	global_position = original_position

func move_upward():
	global_position = original_position + (up_direction)
