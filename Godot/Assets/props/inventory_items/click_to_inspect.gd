class_name ClickableInventoryItem extends ObjectViewerInteractable

var clicked_down : bool = false
var inventory_items_container : InventoryItemsContainer

var tree : SceneTree
var og_scale : Vector3
var resource : InventoryItemResource

func _init(_resource : InventoryItemResource) -> void:
	og_scale = Vector3.ONE*_resource.inventory_scale
	resource = _resource

func _ready() -> void:
	tree = get_tree()
	scale = og_scale
	print("Inventory item ready ", name)

##INHERITED
func enter_hover() -> void:
	if tree == null: return
	var tween : Tween = tree.create_tween()
	tween.tween_property(self, "scale", og_scale*1.2, .2)
	
func exit_hover() -> void:
	if tree == null: return
	var tween : Tween = tree.create_tween()
	tween.tween_property(self, "scale", og_scale, .2)

func on_mouse_down() -> void:
	clicked_down = true

func on_mouse_up() -> void:
	if not clicked_down: return
	clicked_down = false
	InventoryUtils.show_item_details(resource, self)
	
