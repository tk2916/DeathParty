extends CanvasLayer

var screen_size 
var Picture
var timer=Timer.new()

	
func _process(delta):
	Picture=$PictureExample/ViewFinder
	var velocity = Vector2.ZERO 
	if Input.is_action_pressed("move_right"):
		Picture.position.x += 1.5
	if Input.is_action_pressed("move_left"):
		Picture.position.x -= 1.5
	if Input.is_action_pressed("move_down"):
		Picture.position.y += 5
	if Input.is_action_pressed("move_up"):
		Picture.position.y -= 5
		
	if	$PictureExample/ViewFinder.position.x < 0:
		$PictureExample/ViewFinder.position.x = 0
	if	$PictureExample/ViewFinder.position.x > 656:
		$PictureExample/ViewFinder.position.x = 656
	if	$PictureExample/ViewFinder.position.y < 0:
		$PictureExample/ViewFinder.position.y = 0
	if	$PictureExample/ViewFinder.position.y > 328:
		$PictureExample/ViewFinder.position.y = 328

#when picture indicator is pressed, player enters polaroid scene
func _on_questionbutton_pressed() -> void:
	visible=true	
#when player shoots the picture, the image dissapears 
func _on_shoot_pressed() -> void:
	visible=false
	
