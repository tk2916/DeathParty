extends TextureRect

@export var viewfinder_camera: Camera2D

var speed = 100

func _ready():
	viewfinder_camera.make_current()

func _physics_process(delta):
	#if Input.is_action_pressed("move_right"):
		#viewfinder_camera.position.x = position.x
	#if Input.is_action_pressed("move_left"):
		#viewfinder_camera.position.x = position.x
	#if Input.is_action_pressed("move_up"):
		#viewfinder_camera.position.y = position.y
	#if Input.is_action_pressed("move_down"):
		#viewfinder_camera.position.y = position.y
#	camera follows viewfinder but points lower and to the left more
	viewfinder_camera.position = position + Vector2(35, 40)
