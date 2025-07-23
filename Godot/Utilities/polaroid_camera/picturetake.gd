extends Button

@export var object_viewer: Control
@export var polaroid_camera : CanvasLayer

func _on_pressed():
	polaroid_camera.turn_off()
#	can't click again
	disabled=true
	#await get_tree().create_timer(1).timeout
	#object_viewer.set_item("res://polaroid_pop_up.tscn")
	
