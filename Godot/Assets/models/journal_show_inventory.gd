class_name JournalInventoryCollider extends ObjectViewerInteractable

@export var static_page_1 : MeshInstance3D
@export var inventory_items_container : InventoryItemsContainer
@export var journal_root : Journal

var first_time : bool = true
var inventory_showing : bool = false

func e():
	print("E----------")
	print(journal_root.global_position)
	print(static_page_1.global_position)
	print(journal_root.get_node("bookflip/Armature/Skeleton3D/AnimatableBody3D").global_position)
	print("End E-------")

func _ready() -> void:
	inventory_items_container.show_items()

func _on_tree_entered() -> void:
	first_time = true

#INHERITED
func enter_hover() -> void:
	if first_time or inventory_showing: return
	GuiSystem.inventory_showing = true
	journal_root.show_inventory()
	
func exit_hover() -> void:
	if first_time: 
		first_time = false
		return
