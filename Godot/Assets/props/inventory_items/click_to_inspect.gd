class_name ClickableInventoryItem extends ObjectViewerInteractable

var clicked_down : bool = false
var inventory_items_container : InventoryItemsContainer

var tree : SceneTree

func _ready() -> void:
	tree = get_tree()
	
func focus_object():
	var duplicate : ObjectViewerRotatable = ObjectViewerRotatable.new()
	for child in self.get_children():
		if child is CollisionShape3D:
			child.disabled = false
		duplicate.add_child(child.duplicate())
	
	duplicate.scale = Vector3(3,3,3)
	duplicate.rotate(Vector3(1,0,0), deg_to_rad(90.0))
	duplicate.add_to_group("object_viewer_interactable")
	Interact.object_viewer.set_preexisting_item(duplicate)

##INHERITED
func enter_hover():
	if tree == null: return
	var tween = tree.create_tween()
	tween.tween_property(self, "scale", Vector3(1.2,1.2,1.2), .2)
	
func exit_hover():
	if tree == null: return
	var tween = tree.create_tween()
	tween.tween_property(self, "scale", Vector3(1,1,1), .2)

func on_mouse_down():
	clicked_down = true

func on_mouse_up():
	if not clicked_down: return
	clicked_down = false
	focus_object()
	
