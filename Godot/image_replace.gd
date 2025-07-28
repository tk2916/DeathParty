extends MeshInstance3D
@export var Camera_2D : Camera2D
@export var polaroid_camera : CanvasLayer
@export var View_Finder : TextureRect
@export var object_viewer: Control
@onready var og_camera : Camera3D = get_viewport().get_camera_3d()

func _on_shoot_pressed() -> void:
	#hide viewfinder so that when we get the viewport image it doesn't show up
	View_Finder.visible=false
	await get_tree().create_timer(0.09).timeout
	var polaroid=Camera_2D.get_viewport().get_texture().get_image().save_png("user://polaroid_One.png")
	View_Finder.visible=true
	var print_polaroid = Image.load_from_file("user://polaroid_One.png")
	turn_off()
	object_viewer.set_item("res://polaroid_pop_up.tscn")
	SaveSystem.create_new_item("polaroid","",self.get_parent())
	SaveSystem.add_item("polaroid")
#	set the polaroid image 
	material_override.albedo_texture= ImageTexture.create_from_image(print_polaroid)
#function to be called after player takes a picture
#closes the scene 
func turn_off():
	#await get_tree().create_timer(.1).timeout
	polaroid_camera.visible = false
	Camera_2D.enabled=false
	og_camera.make_current()
