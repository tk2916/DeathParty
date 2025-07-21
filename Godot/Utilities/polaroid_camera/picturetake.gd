extends Button

@export var object_viewer: Control
@export var polaroid_camera : CanvasLayer

func _on_pressed():
	var button_pressed_tween: Tween = create_tween()
	button_pressed_tween.set_trans(Tween.TRANS_SINE)
	
	polaroid_camera.turn_off()
	object_viewer.set_item("res://polaroid_pop_up.tscn")
	
