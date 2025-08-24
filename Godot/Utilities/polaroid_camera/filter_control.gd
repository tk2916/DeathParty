extends Node2D

@export var left_button: Button
@export var right_button: Button
@export var filter_base_button :Button
@export var lens: TextureRect
@export var ViewFinder: TextureRect
@export var filter_letter: TextureRect 

@onready var blue_filter: Image = Image.load_from_file("res://Assets/PNGAssets/blue_lens.png")
@onready var red_filter: Image = Image.load_from_file("res://Assets/PNGAssets/red_lens.png")
@onready var green_filter: Image = Image.load_from_file("res://Assets/PNGAssets/green_lens.png")

@onready var N: Image = Image.load_from_file("res://Assets/PNGAssets/N.png")
@onready var R: Image = Image.load_from_file("res://Assets/PNGAssets/R.png")
@onready var G: Image = Image.load_from_file("res://Assets/PNGAssets/G.png")
@onready var B: Image = Image.load_from_file("res://Assets/PNGAssets/B.png")

var lens_color=""

#filter wheel stays in place with the camera 
#is breaking the filter change, when you comment this out it works 
#func _physics_process(delta):
	#position = ViewFinder.position 

#left and right buttons not in use right now buy may change later in game.
#function for when the player turns the filter wheel left 
func _on_left_button_pressed() -> void:
	left_button.disabled=true
	#turns wheel 90 degrees to the left from its current orientation	
	var CurrentRotation=$filter_base.rotation_degrees
	CurrentRotation-= 90
	var tween=create_tween()
	tween.tween_property($filter_base, "rotation",  deg_to_rad(CurrentRotation), .3)
	#prevents player from turning the wheel mid-rotation since turning before tween is finsihed will cause it to turn 90 degrees from the wrong orientation 
	#and the colors on the wheels won't be in their intended positions (top, bottom, left, right)
	await tween.finished
	left_button.disabled=false
	
#function for when player turns the filter wheel right 
func _on_right_button_pressed() -> void:
	right_button.disabled=true
	#turns wheel 90 degrees to the right from its current orientation 
	var CurrentRotation=$filter_base.rotation_degrees
	CurrentRotation+= 90
	var tween=create_tween()
	tween.tween_property($filter_base, "rotation",  deg_to_rad(CurrentRotation), .3)
	#prevents player from turning the wheel mid-rotation since turning before tween is finsihed will cause it to turn 90 degrees from the wrong orientation 
	#and the colors on the wheels won't be in their intended positions (top, bottom, left, right)
	await tween.finished
	right_button.disabled=false

#function for detecting what color is at the top of the wheel (the selected filter) 
func _on_selector_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var lens_color
	#the top of the wheel has an area 2D that detects what color is at the top position and passes that color to the "lens change" function to apply the corresponding filter
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

#function for displaying the filter color 
func lens_change(lens_color: String):
	
	if lens_color=="white":
		lens.visible=false
		filter_letter.texture=ImageTexture.create_from_image(N)
	if lens_color=="blue":
		lens.visible=true
		lens.texture=ImageTexture.create_from_image(blue_filter)
		filter_letter.texture=ImageTexture.create_from_image(B)
		
	if lens_color=="red":
		lens.visible=true
		lens.texture=ImageTexture.create_from_image(red_filter)
		filter_letter.texture=ImageTexture.create_from_image(R)
		
	if lens_color=="green":
		lens.visible=true
		lens.texture=ImageTexture.create_from_image(green_filter)
		filter_letter.texture=ImageTexture.create_from_image(G)
		

#area 2d of the filter base, not in use 
#func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
		#if event is InputEventMouseButton:
			#print('clicked!')

#turns wheel when clicked 

func _on_filter_base_button_pressed() -> void:
	filter_base_button.disabled=true
	#turns wheel 90 degrees to the left from its current orientation	
	var CurrentRotation=$filter_base.rotation_degrees
	CurrentRotation-= 90
	var tween=create_tween()
	tween.tween_property($filter_base, "rotation",  deg_to_rad(CurrentRotation), .3)
	#prevents player from turning the wheel mid-rotation since turning before tween is finsihed will cause it to turn 90 degrees from the wrong orientation 
	#and the colors on the wheels won't be in their intended positions (top, bottom, left, right)
	await tween.finished
	filter_base_button.disabled=false
