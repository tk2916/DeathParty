extends Node2D

@export var filter : ColorRect
@export var left_button: Button
@export var right_button: Button
@export var lens: TextureRect
var lens_color=""
var top_position
#var right_position
#var bottom_position
#var left_position
	
#func _ready():
	#var top_position=$filter_base/white_filter.position
	#var right_position=$filter_base/blue_filter.position
	#var bottom_position=$filter_base/red_filter.position
	#var left_position=$filter_base/green_filter.position
	
func _on_left_button_pressed() -> void:
	var top_position=$filter_base/white_filter.position
	left_button.disabled=true
	var CurrentRotation=$filter_base.rotation_degrees
	CurrentRotation-= 90
	var tween=create_tween()
	tween.tween_property($filter_base, "rotation",  deg_to_rad(CurrentRotation), .3)
	await tween.finished
	filter.visible=true
	tween.tween_property(filter, "modulate",Color(147.0,0.0,0.0,1), .3)
	if top_position==$filter_base/white_filter.global_position:
		filter.visible=false
	if top_position==$filter_base/blue_filter.global_position:
		filter.visible=true
		tween.tween_property(filter, "modulate",Color(40.0,0.0,200.0,0.4), .3)
	if top_position==$filter_base/red_filter.global_position:
		filter.visible=true
		tween.tween_property(filter, "modulate",Color(147.0,0.0,0.0,0.4), .3)
	if top_position==$filter_base/green_filter.global_position:
		filter.visible=true
		tween.tween_property(filter, "modulate",Color(0.0,142.0,19.0,0.4), .3)
	
			#filter[i].position=left_position
			#continue;
		#if filter[i].position==left_position:
			#filter[i].position=bottom_position
			#continue;
		#if filter[i].position==bottom_position:
			#filter[i].position=right_position
			#continue;
		#if filter[i].position==right_position:
			#filter[i].position=top_position

	left_button.disabled=false
	#var filter=[$filter_base/white_filter,$filter_base/blue_filter,$filter_base/red_filter,$filter_base/green_filter]
	#
	#for i in range (4):
		#if filter[i].position==top_position:
			#filter[i].position=left_position
			#continue;
		#if filter[i].position==left_position:
			#filter[i].position=bottom_position
			#continue;
		#if filter[i].position==bottom_position:
			#filter[i].position=right_position
			#continue;
		#if filter[i].position==right_position:
			#filter[i].position=top_position
			#continue;
		
#rotates 
func _on_right_button_pressed() -> void:
	
	right_button.disabled=true
	var CurrentRotation=$filter_base.rotation_degrees
	CurrentRotation+= 90
	var tween=create_tween()
	tween.set_parallel(true)
	tween.tween_property($filter_base, "rotation",  deg_to_rad(CurrentRotation), .3)
	await tween.finished
	right_button.disabled=false
	#var filter = Image.load_from_file("res://Assets/PNGAssets/blue_lens.png")
	#lens.texture=ImageTexture.create_from_image(filter)
	
	#var lens_color = Image.load_from_file("res://Assets/PNGAssets/blue_lens.png")
	#lens.texture=ImageTexture.create_from_image(lens_color)
	
	#for i in range (4):
#instead roatate the whole base 
		#if filter[i].position==top_position:
			#var current= filter[i].position
			#filter[i].position=right_position
			##tween.tween_property(filter[i], "position", right_position,.1)
			#continue;
		#if filter[i].position==right_position:
			#filter[i].position=bottom_position
			##tween.tween_property(filter[i], "position", bottom_position,1)
			#continue;
		#if filter[i].position==bottom_position:
			#filter[i].position=left_position
			##tween.tween_property(filter[i], "position", left_position,1)
			#continue;
		#if filter[i].position==left_position:
			#filter[i].position=top_position
			##tween.tween_property(filter[i], "position", top_position,1)
			#continue;
	#await tween.finished
	#$rotate_right_button/right_button.disabled=false
	

func lens_change(lens_color: String):
	
	var tween=create_tween()
	if lens_color=="white":
		lens.visible=false
	if lens_color=="blue":
		print(lens_color)
		lens.visible=true
		var filter = Image.load_from_file("res://Assets/PNGAssets/blue_lens.png")
		lens.texture=ImageTexture.create_from_image(filter)
		#tween.tween_property(filter, "modulate",Color(40.0,0.0,200.0,0.4), .3)
	if lens_color=="red":
		lens.visible=true
		var filter = Image.load_from_file("res://Assets/PNGAssets/red_lens.png")
		lens.texture=ImageTexture.create_from_image(filter)
		#tween.tween_property(filter, "modulate",Color(147.0,0.0,0.0,0.4), .3)
	if lens_color=="green":
		lens.visible=true
		var filter = Image.load_from_file("res://Assets/PNGAssets/green_lens.png")
		lens.texture=ImageTexture.create_from_image(filter)
		#tween.tween_property(filter, "modulate",Color(0.0,142.0,19.0,0.4), .3)
	



func _on_selector_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var lens_color
	if area.name=="white":
		lens_color="white"
		lens_change(lens_color)
	if area.name=="blue":
		lens_color="blue"
		lens_change(lens_color)
	if area.name=="red":
		lens_color="red"
		lens_change(lens_color)
	if area.name=="green":
		lens_color="green"
		lens_change(lens_color)
	
	
		
