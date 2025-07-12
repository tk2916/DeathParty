extends ObjectViewerInteractable

var up_pos : Vector3
var normal_pos : Vector3
const TWEEN_TIME : float = .2

@export var inventory_items_container : InventoryItemsContainer

var first_time : bool = true
	
func _ready() -> void:
	normal_pos = position
	up_pos = position + Vector3(0,1,0)
	inventory_items_container.load_items()

func show_inventory() -> void:
	if position != normal_pos: return
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", up_pos, TWEEN_TIME)
	inventory_items_container.show_items()
	
func hide_inventory() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", normal_pos, TWEEN_TIME)
	tween.tween_callback(inventory_items_container.hide_items)

##INHERITED
func enter_hover() -> void:
	if first_time: 
		return
	show_inventory()
	
func exit_hover() -> void:
	if first_time: 
		first_time = false
		return
	hide_inventory()
