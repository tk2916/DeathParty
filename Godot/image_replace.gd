extends MeshInstance3D
@export var Camera_2D : Camera2D
@export var View_Finder : TextureRect
@export var object_viewer: Control

#func _on_shoot_button_down() -> void:
##	get screenshot of the current game 
	#View_Finder.visible=false
	#await get_tree().create_timer(.5).timeout
	#var polaroid=Camera_2D.get_viewport().get_texture().get_image().save_png("user://polaroid_One.png")
	#var print_polaroid = Image.load_from_file("user://polaroid_One.png")
##	set the polaroid image 
	#material_override.albedo_texture= ImageTexture.create_from_image(print_polaroid)
#define model in run time 
#inventory refers to file system 
#SaveSystem.add_item("Nora's Polaroid")
#duplicate scene .duplicate function on scenes
#reference 


func _on_shoot_pressed() -> void:
#	hide viewfinder so that when we get the viewport it doesn't show up
	View_Finder.visible=false
#	await get_tree().create_timer(.05).timeout
	var polaroid=Camera_2D.get_viewport().get_texture().get_image().save_png("user://polaroid_One.png")
	View_Finder.visible=true
	await get_tree().create_timer(.029).timeout
	var button_pressed_tween: Tween = create_tween()
	button_pressed_tween.set_trans(Tween.TRANS_SINE)
	var print_polaroid = Image.load_from_file("user://polaroid_One.png")
	object_viewer.set_item("res://polaroid_pop_up.tscn")
	#SaveSystem.create_new_item("polaroid","",polaroid)
	#SaveSystem.add_item("polaroid")
	#var button_pressed_tween: Tween = create_tween()
	#button_pressed_tween.set_trans(Tween.TRANS_SINE)
#	set the polaroid image 
	material_override.albedo_texture= ImageTexture.create_from_image(print_polaroid)
	
