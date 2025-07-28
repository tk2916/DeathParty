extends Button
@export var question_mark : Area3D

func _on_pressed():
	#can't see the question mark once picture is taken
	question_mark.visible=false
	disabled=true
	
	
	

	
