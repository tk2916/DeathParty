class_name ClickableInventoryItem extends ObjectViewerInteractable

var clicked_down : bool = false

##INHERITED
func on_mouse_down():
	clicked_down = true

func on_mouse_up():
	if not clicked_down: return
	clicked_down = false
	
	print("Setting viewed item: ", self.position)
	var duplicate : ObjectViewerRotatable = ObjectViewerRotatable.new()
	for child in self.get_children():
		duplicate.add_child(child.duplicate())
	duplicate.scale = Vector3(2,2,2)
	duplicate.get_node("CollisionShape3D").shape.extents = Vector3(5,5,5)
	Interact.object_viewer.set_preexisting_item(duplicate, true)
	#self.position = Vector3.ZERO
	print("Set viewed item position: ", self.position)
