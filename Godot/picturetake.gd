extends Button
	
func _on_pressed():
	var button_pressed_tween: Tween = create_tween()
	button_pressed_tween.set_trans(Tween.TRANS_SINE)
