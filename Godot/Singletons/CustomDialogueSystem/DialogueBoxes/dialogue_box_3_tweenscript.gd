extends VBoxContainer

@export var diag_rect : TextureRect
var tween : Tween

var duration : float = .2

var boundary_zero : float = 1
var boundary_visible : float = .720
var choice_container_width = .214
var diag_rect_padding = .03

func tweenContainer(child, open):
	print("Tweening!")
	var tree = get_tree()
	tween = tree.create_tween()
	if !open: 
		print("Closing")
		tween.tween_property(self, "anchor_right", boundary_zero + choice_container_width, duration)
		tween.parallel().tween_property(self, "anchor_left", boundary_zero, duration)
		tween.parallel().tween_property(diag_rect, "anchor_right", boundary_zero, duration)
	else:
		print("Opening")
		tween.tween_property(self, "anchor_left", boundary_visible, duration)
		tween.parallel().tween_property(self, "anchor_right", boundary_visible + choice_container_width, duration)
		tween.parallel().tween_property(diag_rect, "anchor_right", boundary_visible + diag_rect_padding, duration)

func tweenOpen(child):
	tweenContainer(child, true)

func tweenClose(child):
	var num_children : int = get_child_count()
	if num_children == 1: #1, meaning the last child is exiting
		tweenContainer(child, false)

func _ready() -> void:
	print("TweenScript is ready!")
	child_entered_tree.connect(tweenOpen)
	child_exiting_tree.connect(tweenClose)
	anchor_right = boundary_zero + choice_container_width
	anchor_left = boundary_zero
	diag_rect.anchor_right = boundary_zero
