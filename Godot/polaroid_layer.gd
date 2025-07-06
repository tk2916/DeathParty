extends CanvasLayer

var Picture
	
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
	if	$PictureExample/ViewFinder.position.x > 100:
		$PictureExample/ViewFinder.position.x = 100
	if	$PictureExample/ViewFinder.position.y < 0:
		$PictureExample/ViewFinder.position.y = 0
	if	$PictureExample/ViewFinder.position.y > 142:
		$PictureExample/ViewFinder.position.y = 142

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		print("interact")
		$PictureExample/ViewFinder/Camera2D.enabled=true
		$PictureExample/ViewFinder/Camera2D.make_current()
		visible=true	
#when player shoots the picture, the image dissapears 
func _on_shoot_button_up() -> void:
	visible=false
	$PictureExample/ViewFinder/Camera2D.enabled=false

#when question mark is pressed, player enters polaroid scene
