class_name JournalHider extends JournalInventoryCollider

#INHERITED
func enter_hover() -> void:
	print("Enter hover hide")
	if GuiSystem.inventory_showing:
		print("New grabbed object: ", Interact.grabbed_object)
		GuiSystem.inventory_showing = false
		journal_root.hide_inventory()
