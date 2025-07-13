extends CanvasLayer

var Picture

#function for movement of camera
func _physics_process(delta: float) -> void:
	Picture=$PictureExample/ViewFinder
	var velocity = Vector2.ZERO 
	# viewfinder movement corresponds with player input	
	if Input.is_action_pressed("move_right"):
		Picture.position.x += 1.5
	if Input.is_action_pressed("move_left"):
		Picture.position.x -= 1.5
	if Input.is_action_pressed("move_down"):
		Picture.position.y += 5
	if Input.is_action_pressed("move_up"):
		Picture.position.y -= 5
	#stops viewfinder from passing the bounds of the image
	if	$PictureExample/ViewFinder.position.x < 0:
		$PictureExample/ViewFinder.position.x = 0

	if $PictureExample/ViewFinder.position.x > 100:
		$PictureExample/ViewFinder.position.x = 100

	if $PictureExample/ViewFinder.position.y < 0:
		$PictureExample/ViewFinder.position.y = 0

	if $PictureExample/ViewFinder.position.y > 142:
		$PictureExample/ViewFinder.position.y = 142
#function for when player clicks the question mark 
#func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	## detects when player click on question mark
	#if event is InputEventMouseButton:
		##pops up picture taking scene,switch to 2D camera	
		#$PictureExample/ViewFinder/Camera2D.enabled=true
		#$PictureExample/ViewFinder/Camera2D.make_current()
		#visible=true	
#when player shoots the picture, the scene goes away
func _on_shoot_button_up() -> void:
	#var x: float=$PictureExample/ViewFinder/Camera2D.global_position.x
	#var y: float=$PictureExample/ViewFinder/Camera2D.global_position.y
	#var height: float=570
	#var width: float=1165
	#var region = Rect2(x,y, 480, 296) 
	#want a specific part of the viewpart, where camera is 
	#takes a second to load 
	var polaroid = get_viewport().get_texture().get_image()
	$PictureExample/ViewFinder/Camera2D.enabled=false
	polaroid.save_png("user://polaroid_One.png")
	load_polaroid()

func load_polaroid():
	#loads image of viewport, dissapears after 2 seconds
	var print_polaroid = Image.load_from_file("user://polaroid_One.png")
	await get_tree().create_timer(2.0,true).timeout
	visible=false
#when question mark is pressed, player enters polaroid scene

func _on_question_mark_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	# detects when player click on question mark
	print("clicked")
	if event is InputEventMouseButton:
		#pops up picture taking scene,switch to 2D camera	
		$PictureExample/ViewFinder/Camera2D.enabled=true
		$PictureExample/ViewFinder/Camera2D.make_current()
		visible=true	
		
#when player shoots the picture, the scene goes away
