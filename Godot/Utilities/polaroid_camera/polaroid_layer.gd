class_name PolaroidLayer extends CanvasLayer


var Picture
@export var viewfinder_camera: Camera2D


func _ready() -> void:
	Globals.polaroid_camera_ui = self


#function for movement of camera
func _physics_process(delta: float) -> void:
	Picture = $PictureExample/ViewFinder
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
	if $PictureExample/ViewFinder.position.x < 0:
		$PictureExample/ViewFinder.position.x = 0

	if $PictureExample/ViewFinder.position.x > 100:
		$PictureExample/ViewFinder.position.x = 100

	if $PictureExample/ViewFinder.position.y < 0:
		$PictureExample/ViewFinder.position.y = 0

	if $PictureExample/ViewFinder.position.y > 142:
		$PictureExample/ViewFinder.position.y = 142
		
#function for when question mark is pressed 
func _on_question_mark_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	# detects when player clicks on question mark
	if event is InputEventMouseButton:
		#pops up picture taking scene and switch to 2D camera	
		$PictureExample/Camera2D.enabled = true
		$PictureExample/Camera2D.make_current()
		visible = true
