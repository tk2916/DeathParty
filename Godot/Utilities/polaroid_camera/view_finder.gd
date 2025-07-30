extends TextureRect

@export var viewfinder_camera: Camera2D

var speed = 100

func _ready():
	viewfinder_camera.make_current()

func _physics_process(delta):
	viewfinder_camera.position = position + Vector2(35, 40)
