class_name SocialMediaApp extends Control

@export var back_button : Button

@export var image_label : TextureRect
@export var name_label : RichTextLabel
@export var tag_label : RichTextLabel
@export var quote_label : RichTextLabel
@export var join_date_label : RichTextLabel
@export var friends_label : RichTextLabel

var user_pressed : bool = false

var duration : float = 0.5

var left_anchor_before : float
var right_anchor_before : float

var left_anchor_after : float
var right_anchor_after : float

func _ready() -> void:
	left_anchor_before = anchor_left
	right_anchor_before = anchor_right
	left_anchor_after = left_anchor_before-1
	right_anchor_after = right_anchor_before-1
	
	back_button.pressed.connect(tween_backward)

func user_pressed_false():
	user_pressed = false

func on_user_pressed(char_resource : CharacterResource) -> void:
	print("User pressed! :", char_resource.name)
	if user_pressed: return # prevent multiple presses
	user_pressed = true
	
	## Apply profile info
	image_label.texture = char_resource.image_profile
	name_label.text = char_resource.name
	tag_label.text = char_resource.profile_tag
	quote_label.text = char_resource.profile_quote
	join_date_label.text = char_resource.profile_join_date
	friends_label.text = str(char_resource.profile_friends) + " friends"
	
	tween_forward().finished.connect(user_pressed_false)
	
func tween_forward() -> Tween:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "anchor_left", left_anchor_after, duration)
	tween.parallel().tween_property(self, "anchor_right", right_anchor_after, duration)
	return tween

func tween_backward() -> Tween:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "anchor_left", left_anchor_before, duration)
	tween.parallel().tween_property(self, "anchor_right", right_anchor_before, duration)
	return tween
