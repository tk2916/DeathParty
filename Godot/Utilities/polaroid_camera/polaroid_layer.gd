extends CanvasLayer

var Picture

@export var viewfinder_camera: Camera2D
@onready var og_camera : Camera3D = get_viewport().get_camera_3d()

#function for movement of camera
func _physics_process(delta: float) -> void:
	Picture=$PictureExample/ViewFinder
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
	if	$PictureExample/ViewFinder.position.x < 0:
		$PictureExample/ViewFinder.position.x = 0

	if $PictureExample/ViewFinder.position.x > 100:
		$PictureExample/ViewFinder.position.x = 100

	if $PictureExample/ViewFinder.position.y < 0:
		$PictureExample/ViewFinder.position.y = 0

	if $PictureExample/ViewFinder.position.y > 142:
		$PictureExample/ViewFinder.position.y = 142

#func _on_shoot_button_up() -> void:
	
	#var polaroid=$PictureExample/Camera2D.get_viewport().get_texture().get_image().save_png("user://polaroid_One.png")
	#$PictureExample/Camera2D.enabled=false
	#load_polaroid()

#func load_polaroid():
	#loads image of viewport, dissapears after 2 seconds
	#var print_polaroid = Image.load_from_file("user://polaroid_One.png")
#	sets the viewfinde rimage to the image taken, just for testing 
	#$PictureExample/ViewFinder.texture=ImageTexture.create_from_image(print_polaroid)
	#await get_tree().create_timer(5).timeout
	#visible=false

#when question mark is pressed, player enters polaroid scene
func _on_question_mark_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	# detects when player click on question mark
	print("clicked")
	if event is InputEventMouseButton:
		#pops up picture taking scene,switch to 2D camera	
		$PictureExample/Camera2D.enabled=true
		$PictureExample/Camera2D.make_current()
		visible=true	
#when player shoots the picture, the scene goes away
func turn_off():
	await get_tree().create_timer(3).timeout
	visible = false
	$PictureExample/Camera2D.enabled=false
	og_camera.make_current()
