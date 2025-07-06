extends CanvasLayer


var picture


func _physics_process(delta: float) -> void:
	picture = $PictureExample/ViewFinder
	var velocity = Vector2.ZERO 
	if Input.is_action_pressed("move_right"):
		picture.position.x += 1.5
	if Input.is_action_pressed("move_left"):
		picture.position.x -= 1.5
	if Input.is_action_pressed("move_down"):
		picture.position.y += 5
	if Input.is_action_pressed("move_up"):
		picture.position.y -= 5

	if $PictureExample/ViewFinder.position.x < 0:
		$PictureExample/ViewFinder.position.x = 0

	if $PictureExample/ViewFinder.position.x > 100:
		$PictureExample/ViewFinder.position.x = 100

	if $PictureExample/ViewFinder.position.y < 0:
		$PictureExample/ViewFinder.position.y = 0

	if $PictureExample/ViewFinder.position.y > 142:
		$PictureExample/ViewFinder.position.y = 142


# when question mark is pressed, player enters polaroid scene
func _on_picture_hint_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		print("interact")
		$PictureExample/ViewFinder/Camera2D.enabled=true
		$PictureExample/ViewFinder/Camera2D.make_current()
		visible=true
		get_tree().paused = true


# when player shoots the picture, the image disappears 
func _on_shoot_button_up() -> void:
	visible=false
	$PictureExample/ViewFinder/Camera2D.enabled=false
	get_tree().paused = false
