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
	
#func focus_object():
	#GuiSystem.hide_journal()
	#var duplicate : ObjectViewerRotatable = ObjectViewerRotatable.new()
	#for child in self.get_children():
		#if child is CollisionShape3D:
			#child.disabled = false
		#duplicate.add_child(child.duplicate())
	#
	#duplicate.scale = Vector3.ONE*3
	##duplicate.rotate(Vector3(0,1,0), deg_to_rad(180.0))
	#
	#Interact.object_viewer.set_preexisting_item(duplicate)
	#Interact.object_viewer.view_item_info(resource.name, resource.description)

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
	
