class_name JournalInventoryCollider extends ObjectViewerInteractable

@export var static_page_1 : MeshInstance3D
@export var inventory_items_container : InventoryItemsContainer
@export var journal_root : Journal

var inventory_showing : bool = false

func _ready() -> void:
	inventory_items_container.show_items()

#INHERITED
func enter_hover() -> void:
	if inventory_showing: return
	GuiSystem.inventory_showing = true
	journal_root.show_inventory()
