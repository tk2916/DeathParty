extends MeshInstance3D

@export var button : Button
var original_position : Vector3 = self.position
var up_direction : Vector3 = Vector3.UP

@export var flip_to_page : int

func return_to_original_pos():
	position = original_position

func button_pressed():
	position = original_position + (up_direction * .1)
