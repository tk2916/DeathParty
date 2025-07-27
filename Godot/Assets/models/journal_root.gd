class_name Journal extends Node3D

@onready var show_inventory_sound: FmodEventEmitter2D = %ShowInventorySound
@onready var hide_inventory_sound: FmodEventEmitter2D = %HideInventorySound

var up_pos : Vector3
var normal_pos : Vector3
var og_scale : Vector3 = Vector3.ONE
const TWEEN_TIME : float = .5

@export var bookflip : BookFlip

func _ready() -> void:
	normal_pos = position
	up_pos = normal_pos - transform.basis.z.normalized()
	og_scale = scale
	Interact.main_page_static = $book_static/StaticPage1

func reset_properties() -> void:
	print("Position before: ", position)
	position = Vector3.ZERO
	scale = og_scale

func show_inventory() -> void:
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", og_scale*.65, TWEEN_TIME)
	tween.tween_property(self, "position", up_pos, TWEEN_TIME)
	show_inventory_sound.play()

func hide_inventory() -> void:
	print("Hiding: ", self, get_tree())
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", og_scale, TWEEN_TIME)
	tween.tween_property(self, "position", normal_pos, TWEEN_TIME)
	hide_inventory_sound.play()
