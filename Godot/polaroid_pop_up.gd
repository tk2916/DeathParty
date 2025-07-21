extends StaticBody3D

@export var object_viewer: Control

#func _ready() -> void:
	#position = get_viewport().size/3 #vectors support dividing by scalars

func _on_shoot_button_up() -> void: pass
	#on shoot the polaroid pops up
	#visible=true
#	background blurs but the polaroid does too but we want it to be the focus 
	#object_viewer.set_item("res://Assets/props/inventory_items/polaroid_nora.tscn")
	#object_viewer.visible=true 
	#waits 5 seconds before dissapearing 
	#await get_tree().create_timer(5.0,true).timeout
