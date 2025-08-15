extends MeshInstance3D
@export var Camera_2D : Camera2D
@export var polaroid_camera : CanvasLayer
@export var View_Finder : TextureRect
@export var object_viewer: Control
@export var filter_control: Node2D
@onready var og_camera : Camera3D = get_viewport().get_camera_3d()

func _on_shoot_pressed() -> void:
	#hide viewfinder from final image
	
	View_Finder.visible=false
	filter_control.visible=false
	#await RenderingServer.frame_post_draw
	await get_tree().create_timer(0.2).timeout
	var polaroid=Camera_2D.get_viewport().get_texture().get_image().save_png("user://polaroid_One.png")
	await get_tree().create_timer(0.5).timeout
	View_Finder.visible=true
	filter_control.visible=true
	var print_polaroid = Image.load_from_file("user://polaroid_One.png")
	object_viewer.set_item("res://polaroid_pop_up.tscn")
	SaveSystem.create_new_item("polaroid","",self.get_parent())
	SaveSystem.add_item("polaroid")
	material_override.albedo_texture= ImageTexture.create_from_image(print_polaroid)

#closes the scene 
#is called in the "shoot" button function 
func turn_off():
	#await get_tree().create_timer(.1).timeout
	polaroid_camera.visible = false
	Camera_2D.enabled=false
	og_camera.make_current()
