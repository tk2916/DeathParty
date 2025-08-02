class_name SocialMediaApp extends Control

@export var back_button : Button

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
	
	back_button.pressed.connect(tweenBackward)

func user_pressed_false():
	user_pressed = false

func on_user_pressed(user : CharacterResource) -> void:
	print("User pressed! :", user.name)
	if user_pressed: return # prevent multiple presses
	user_pressed = true
	tweenForward().finished.connect(user_pressed_false)
	
func tweenForward() -> Tween:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "anchor_left", left_anchor_after, duration)
	tween.parallel().tween_property(self, "anchor_right", right_anchor_after, duration)
	return tween

func tweenBackward() -> Tween:
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "anchor_left", left_anchor_before, duration)
	tween.parallel().tween_property(self, "anchor_right", right_anchor_before, duration)
	return tween
