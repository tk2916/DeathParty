class_name Journal extends ObjectViewerInteractable

@onready var show_inventory_sound: FmodEventEmitter2D = %ShowInventorySound
@onready var hide_inventory_sound: FmodEventEmitter2D = %HideInventorySound

@export var static_page_1 : MeshInstance3D

var up_pos : Vector3
var normal_pos : Vector3
var og_scale : Vector3
const TWEEN_TIME : float = .2

@export var inventory_items_container : InventoryItemsContainer

var first_time : bool = true
var inventory_showing : bool = false
	
func _init() -> void:
	normal_pos = position
	up_pos = position + Vector3(0,1,0)

func show_inventory() -> void:
	print("Showing inventory")
	og_scale = scale
	print("Og scale: ", og_scale)
	var tween = get_tree().create_tween()
	#tween.tween_property(self, "position", up_pos, TWEEN_TIME)
	tween.tween_property(self, "scale", og_scale*.7, TWEEN_TIME)
	inventory_items_container.show_items()
	show_inventory_sound.play()

func hide_inventory() -> void:
	print("Hide inventory")
	var tween = get_tree().create_tween()
	#tween.tween_property(self, "position", normal_pos, TWEEN_TIME)
	tween.tween_property(self, "scale", og_scale, TWEEN_TIME)
	tween.tween_callback(inventory_items_container.hide_items)
	hide_inventory_sound.play()

#INHERITED
func enter_hover() -> void:
	if first_time or inventory_showing: return
	inventory_showing = true
	show_inventory()
	
func exit_hover() -> void:
	if first_time: 
		first_time = false
		return
	if inventory_showing:
		inventory_showing = false
		hide_inventory()
