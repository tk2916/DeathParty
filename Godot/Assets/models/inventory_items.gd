class_name InventoryItemsContainer extends Node3D

@export var static_page_1 : MeshInstance3D
@export var bookflip_instance : BookFlip

@onready var main_page : MeshInstance3D = bookflip_instance.page1

var player_inventory : Dictionary[String, int]

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

func on_inventory_change(action:String, item:String) -> void:
	var itemCount = SaveSystem.item_count(item)
	if action == "remove" and itemCount == 0:
		delete_item(item)
		return
	elif action == "add" and itemCount == 1:
		new_item(item)
		refresh_items()

func find_first_mesh(item : Node3D):
	for thing in item.get_children():
		if thing is MeshInstance3D:
			return thing

func create_clickable_item(item_resource : InventoryItemResource, item : Node3D) -> ObjectViewerInteractable:
	var static_body : ObjectViewerInteractable
	if item.name.substr(0,8) == "polaroid":
		static_body = DragDropPolaroid.new(item_resource, static_page_1, bookflip_instance)
		#static_body.main_page = main_page
	else:
		static_body = ClickableInventoryItem.new(item_resource)
	
	static_body.name = item_resource.name
	var collision_shape : CollisionShape3D = CollisionShape3D.new()
	collision_shape.name = "CollisionShape3D"
	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.extents = Vector3(.2,.5,.2)
	
	static_body.global_position = item.global_position
	static_body.add_child(collision_shape)
	static_body.add_child(item)
	
	item.position = Vector3.ZERO
	item.rotate(Vector3(1,0,0), deg_to_rad(90))
	item.rotate(Vector3(0,1,0), deg_to_rad(180))
	
	return static_body
	
func new_item(item_name:String):
	var item_resource : InventoryItemResource = SaveSystem.inventory_item_to_resource[item_name]
	var model : PackedScene = item_resource.model
	var instance : Node3D = model.instantiate()
	var static_body : ObjectViewerInteractable = create_clickable_item(item_resource, instance)
	item_instances.push_back(static_body)
	print("Static body name: ", static_body.name)

func delete_item(item_name:String):
	var position = 0
	for item in item_instances:
		if item.name == item_name:
			self.remove_child(item)
			item.queue_free()
			item_instances.remove_at(position)
			break
		position += 1

func load_items() -> void:
	print("Loading items!")
	player_inventory = SaveSystem.get_inventory()
	for item in player_inventory:
		if player_inventory[item] == 0: continue
		new_item(item)
	#show_items()

func show_items() -> void:
	items_showing = true
	var item_index : int = 0
	for item in item_instances:
		var item_pos : Vector2 = SaveSystem.inventory_item_to_resource[item.name].inventory_position
		var item_pos_3d : Vector3 = Vector3(item_pos.x, 0, item_pos.y)
		item.position = item_pos_3d#item_positions_grid[item_index]
		self.add_child(item)
		item_index+=1

func hide_items() -> void:
	items_showing = false
	for item in get_children():
		self.remove_child(item)
		
func refresh_items():
	var old_items_showing : bool = items_showing
	hide_items()
	if old_items_showing:
		show_items()
