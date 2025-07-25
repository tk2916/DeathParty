class_name Journal extends ObjectViewerInteractable

@onready var show_inventory_sound: FmodEventEmitter2D = %ShowInventorySound
@onready var hide_inventory_sound: FmodEventEmitter2D = %HideInventorySound

@export var static_page_1 : MeshInstance3D

var up_pos : Vector3
var normal_pos : Vector3
const TWEEN_TIME : float = .2

@export var inventory_items_container : InventoryItemsContainer

var first_time : bool = true

var tree : SceneTree
	
func _init() -> void:
	normal_pos = position
	up_pos = position + Vector3(0,1,0)
	#print("Calling load items from bookflipbody")
	#inventory_items_container.load_items()
	
	tree = get_tree()
	#show_inventory()

#func show_inventory() -> void:
	#if position != normal_pos: return
	#if not tree: return
	##var tween = tree.create_tween()
	##tween.tween_property(self, "position", up_pos, TWEEN_TIME)
	##inventory_items_container.load_items()
	##show_inventory_sound.play()
#
#func hide_inventory() -> void:
	#var tween = tree.create_tween()
	#if not tree: return
	#tween.tween_property(self, "position", normal_pos, TWEEN_TIME)
	#tween.tween_callback(inventory_items_container.hide_items)
	#hide_inventory_sound.play()

##INHERITED
#func enter_hover() -> void:
	##if first_time: 
		##return
	#show_inventory()
	#
#func exit_hover() -> void:
	##if first_time: 
		##first_time = false
		##return
	#hide_inventory()
