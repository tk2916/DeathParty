class_name Collectable extends Interactable

@export var item_resource : InventoryItemResource

func on_interact() -> void:
	print("Collected item: ", item_resource.name)
	InventoryUtils.show_item_details(item_resource)
	SaveSystem.add_item(item_resource.name)
	
