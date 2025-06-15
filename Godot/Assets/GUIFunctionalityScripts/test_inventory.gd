extends ColorRect

@export var vbox : VBoxContainer
var item_gui = preload("res://test_inventory_item.tscn")

var item_to_label = {}

func new_item(item:String):
	var newitem = item_gui.instantiate()
	item_to_label[item] = newitem
	vbox.add_child(newitem)
	
func update_item(item:String, itemCount:int):
	item_to_label[item].text = "[color=black]" + item + ": " + str(itemCount) + "[/color]"

func on_inventory_change(action:String, item:String):
	var itemCount = SaveSystem.item_count(item)#SaveSystem.player_data["inventory"][item]
	if action == "remove" and itemCount == 0:
		item_to_label[item].queue_free()
		return
	elif action == "add" and itemCount == 1:
		new_item(item)
	update_item(item, itemCount)
	
func on_load():
	print("loading items...")
	for item in SaveSystem.player_data["inventory"]:
		var itemCount = SaveSystem.player_data["inventory"][item]
		if itemCount > 0:
			new_item(item)
			update_item(item, itemCount)

func _ready() -> void:
	SaveSystem.inventory_changed.connect(on_inventory_change)
	on_load()
