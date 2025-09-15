class_name PhoneNotification extends Control

@export var root : Control
@export var exclamation : TextureRect
@export var image_container : TextureRect
@export var name_label : RichTextLabel
@export var button : Button

var default_left_anchor : float
var default_right_anchor : float
var out_left_anchor : float
var out_right_anchor : float

const OUT_ANCHOR_OFFSET := 0.76

var tree : SceneTree

var seen : bool = false
var finished_sliding_in : bool = false

var exclamation_timer : Timer
const FLASH_DELAY := .15
var exclamation_counter = 0

func _ready() -> void:
	visible = false
	exclamation.visible = false
	
	default_left_anchor = root.anchor_left
	default_right_anchor = root.anchor_right
	out_left_anchor = default_left_anchor+OUT_ANCHOR_OFFSET
	out_right_anchor = default_right_anchor+OUT_ANCHOR_OFFSET
	
	root.anchor_left = default_left_anchor+1
	root.anchor_right = default_right_anchor+1
	visible = true
	
	tree = get_tree()
	exclamation_timer = Timer.new()
	exclamation_timer.wait_time = FLASH_DELAY
	exclamation_timer.autostart = true
	exclamation_timer.timeout.connect(toggle_exclamation)
	add_child(exclamation_timer)
	slide(true)

func set_picture(resource : ChatResource):
	image_container.texture = resource.image
	
func set_notif_name(resource : ChatResource):
	name_label.text = resource.name
	button.contact_resource = resource
	
func toggle_exclamation(active:bool = true) -> void:
	if !finished_sliding_in: return
	if active and exclamation_counter < 3:
		exclamation_counter += 1
		exclamation.visible = !exclamation.visible
	else:
		exclamation.visible = false
		if exclamation_timer:
			exclamation_timer.queue_free()
			exclamation_timer = null

func slide(into_screen : bool) -> void:
	var new_anchor_left : float
	var new_anchor_right : float
	if into_screen:
		new_anchor_left = default_left_anchor
		new_anchor_right = default_right_anchor
	else:
		new_anchor_left = out_left_anchor
		new_anchor_right = out_right_anchor
	var tween : Tween = tree.create_tween()
	tween.tween_property(root, "anchor_left", new_anchor_left, .2)
	tween.parallel().tween_property(root, "anchor_right", new_anchor_right, .2)
	if !into_screen or seen: return
	#ONLY ON FIRST SLIDE IN
	tween.finished.connect(
		func()->void: finished_sliding_in = true
		)
	await tree.create_timer(3).timeout
	seen = true
	toggle_exclamation(false)
	slide(false)
