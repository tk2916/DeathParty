class_name Journal extends Node3D

@onready var show_inventory_sound: FmodEventEmitter2D = %ShowInventorySound
@onready var hide_inventory_sound: FmodEventEmitter2D = %HideInventorySound
@onready var journal_music: FmodEventEmitter3D = %JournalMusic

var up_pos : Vector3
var normal_pos : Vector3
var og_scale : Vector3 = Vector3.ONE*.8
const TWEEN_TIME : float = .5

@export var bookflip : BookFlip
var arrow_down : Sprite3D

func _ready() -> void:
	if bookflip:
		arrow_down = bookflip.get_node("ArrowDown")
	normal_pos = position
	up_pos = normal_pos - transform.basis.z.normalized()*.65
	og_scale = scale
	Interact.main_page_static = $book_static/StaticPage1

func reset_properties() -> void:
	print("Position before: ", position)
	position = Vector3.ZERO
	scale = og_scale

func show_inventory() -> void:
	var tween : Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", og_scale*.65, TWEEN_TIME)
	tween.tween_property(self, "position", up_pos, TWEEN_TIME)
	show_inventory_sound.play()
	arrow_down.visible = false


func hide_inventory() -> void:
	print("Hiding: ", self, get_tree())
	var tween : Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", og_scale, TWEEN_TIME)
	tween.tween_property(self, "position", normal_pos, TWEEN_TIME)
	hide_inventory_sound.play()
	arrow_down.visible = true


func _on_music_timer_timeout() -> void:
	journal_music.play()
