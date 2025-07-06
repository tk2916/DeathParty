extends TextureRect


var speed = 100


func _ready():
	$Camera2D.make_current()


func _physics_process(delta):
	if Input.is_action_pressed("move_right"):
		position.x +=2
	if Input.is_action_pressed("move_left"):
		position.x -=2
	if Input.is_action_pressed("move_up"):
		position.y +=2
	if Input.is_action_pressed("move_down"):
		position.y -=2
