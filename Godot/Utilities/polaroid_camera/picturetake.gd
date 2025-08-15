extends Button
@export var question_mark : Area3D
@export var Polaroid_image : MeshInstance3D

func _on_pressed():
	#question_mark.visible=false
	#disabled=true
	await get_tree().create_timer(0.3).timeout
	#code for flash 
	$flash.visible=true
	var tween=create_tween()
	tween.tween_property($flash, "modulate:a", 0, 1)
	await tween.finished
	#await get_tree().create_timer(1.2).timeout
	Polaroid_image.turn_off()
	

	
