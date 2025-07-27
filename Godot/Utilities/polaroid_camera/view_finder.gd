extends TextureRect

@export var polaroid_layer : PolaroidLayer
var speed = 100


func _ready():
	$Camera2D.make_current()


func _physics_process(delta):
	if polaroid_layer.visible:
		if Input.is_action_pressed("move_right"):
			position.x +=2
		if Input.is_action_pressed("move_left"):
			position.x -=2
		if Input.is_action_pressed("move_up"):
			position.y +=2
		if Input.is_action_pressed("move_down"):
			position.y -=2
