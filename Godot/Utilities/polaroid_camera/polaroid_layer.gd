class_name PolaroidLayer extends CanvasLayer

var Picture

@export var viewfinder_camera: Camera2D


#func start():
	#print("start function started")
	#Picture=$body/MainImage/ViewFinder
	#Picture.position.y=220
	#while Picture.position.y <0.0:
		#Picture.position.y -= 1 
	
#function for movement of camera
func _physics_process(delta) -> void:
	Picture=$body/MainImage/ViewFinder
	# viewfinder movement corresponds with player input	
	if Input.is_action_pressed("move_right"):
		Picture.position.x += 3
	if Input.is_action_pressed("move_left"):
		Picture.position.x -= 3
	if Input.is_action_pressed("move_down"):
		Picture.position.y += 3
	if Input.is_action_pressed("move_up"):
		Picture.position.y -= 3
	#stops viewfinder from passing the bounds of the image
	if	Picture.position.x < -71:
		Picture.position.x = -71

	if Picture.position.x > 550:
		Picture.position.x = 550

	if Picture.position.y < 0:
		Picture.position.y = 0

	if Picture.position.y > 155:
		Picture.position.y = 155
	
	print(Picture.position.y)
#function for when question mark is pressed 
func _on_question_mark_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	# detects when player clicks on question mark
	if event is InputEventMouseButton:
		#pops up picture taking scene and switch to 2D camera	
		$body/MainImage/Camera2D.enabled=true
		$body/MainImage/Camera2D.make_current()
		visible=true	
