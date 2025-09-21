class_name PolaroidLayer extends CanvasLayer

var Picture
@export var viewfinder_camera: Camera2D



func _ready():
	viewfinder_camera.make_current()
 
#function for movement of camera
func _physics_process(delta) -> void:
	Picture=$body/MainImage
	# picture movement corresponds with player input	
	#error: awsd moves player at the same time			
	if Input.is_action_pressed("move_right"):
		Picture.position.x -= 3
	if Input.is_action_pressed("move_left"):
		Picture.position.x += 3
	if Input.is_action_pressed("move_down"):
		Picture.position.y -= 3
	if Input.is_action_pressed("move_up"):
		Picture.position.y += 3
	
	#keeps image within the bounds a
	print (Picture.position)

	if Picture.position.x > 0:
		Picture.position.x =0
	
	if	Picture.position.x < -(Picture.size.x*Picture.scale.x-get_viewport().size.x):
		Picture.position.x = -(Picture.size.x*Picture.scale.x-get_viewport().size.x)

	if Picture.position.y > 0:
		Picture.position.y = 0
		
	if	Picture.position.y < -(Picture.size.y*Picture.scale.y-get_viewport().size.y):
		Picture.position.y = -(Picture.size.y*Picture.scale.y-get_viewport().size.y)
	#
#function for when question mark is pressed 
func _on_question_mark_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	# detects when player clicks on question mark
	if event is InputEventMouseButton:
		#pops up picture taking scene and switch to 2D camera	
		$body/MainImage/Camera2D.enabled=true
		$body/MainImage/Camera2D.make_current()
		visible=true	
