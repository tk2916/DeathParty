class_name InventoryItemsContainer extends Node3D

@export var static_page_1 : MeshInstance3D
@export var bookflip_instance : BookFlip

@onready var main_page : MeshInstance3D = bookflip_instance.page1

var player_inventory : Dictionary[String, InventoryItemResource]

var item_instances : Array[Node3D]

var item_positions_grid : Array[Vector3]
var spacer : float = 1
var double_spacer : float = 2*spacer

var items_showing : bool = false

func _init() -> void:
	#set grid positions IN ORDER of where we want items to appear (center-outward)
	item_positions_grid.push_back(Vector3.ZERO)
	item_positions_grid.push_back(Vector3(-spacer,0,0))
	item_positions_grid.push_back(Vector3(spacer,0,0))
	item_positions_grid.push_back(Vector3(-(double_spacer),0,0))
	item_positions_grid.push_back(Vector3(double_spacer,0,0))
	#2nd row
	item_positions_grid.push_back(Vector3(0,-double_spacer,0))
	item_positions_grid.push_back(Vector3(-spacer,-double_spacer,0))
	item_positions_grid.push_back(Vector3(spacer,-double_spacer,0))
	item_positions_grid.push_back(Vector3(-(double_spacer),-double_spacer,0))
	item_positions_grid.push_back(Vector3(double_spacer,-double_spacer,0))
	
	SaveSystem.inventory_changed.connect(on_inventory_change)
	load_items()
	hide_items()

func on_inventory_change(action:String, item:InventoryItemResource) -> void:
	var itemCount : int = item.amount_owned
	if action == "remove" and itemCount == 0:
		delete_item(item.name)
		return
	elif action == "add" and itemCount == 1:
		new_item(item.name)
		refresh_items()
	
func new_item(item_name:String) -> void:
	var item_resource : InventoryItemResource = SaveSystem.get_inventory_item(item_name)
	var static_body : ObjectViewerInteractable = InventoryUtils.create_clickable_item(item_resource)
	item_instances.push_back(static_body)
	#print("Static body name: ", static_body.name)

func delete_item(item_name:String) -> void:
	var index : int = 0
	for item in item_instances:
		if item.name == item_name:
			self.remove_child(item)
			item.queue_free()
			item_instances.remove_at(index)
			break
		index += 1

func load_items() -> void:
	#print("Loading items!")
	player_inventory = SaveSystem.get_inventory()
	for item_name : String in player_inventory:
		var item : InventoryItemResource = player_inventory[item_name]
		if item.amount_owned == 0: continue
		new_item(item_name)
	#show_items()

func show_items() -> void:
	items_showing = true
	for item in item_instances:
		var item_pos : Vector2 = SaveSystem.get_inventory_item(item.name).inventory_position
		var item_pos_3d : Vector3 = Vector3(item_pos.x, 0, item_pos.y)
		item.position = item_pos_3d
		self.add_child(item)

func hide_items() -> void:
	items_showing = false
	for item in get_children():
		self.remove_child(item)
		
func refresh_items() -> void:
	var old_items_showing : bool = items_showing
	hide_items()
	if old_items_showing:
		show_items()
