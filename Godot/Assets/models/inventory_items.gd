class_name InventoryItemsContainer extends Node3D

@export var bookflip_instance : BookFlip
@onready var main_page : MeshInstance3D = bookflip_instance.page1

var player_inventory : Dictionary[String, int]

var item_instances : Array[Node3D]

var item_positions_grid : Array[Vector3]
var spacer : float = .5
var double_spacer : float = 2*spacer

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

func find_first_mesh(item : Node3D):
	for thing in item.get_children():
		if thing is MeshInstance3D:
			return thing

func create_clickable_item(item : Node3D, index : int) -> ObjectViewerInteractable:
	var static_body : ObjectViewerInteractable
	if item.name.substr(0,8) == "polaroid":
		static_body = DragDropPolaroid.new(bookflip_instance)
		#static_body.main_page = main_page
	else:
		static_body = ClickableInventoryItem.new()
	
	static_body.name = "InventoryItem-" + str(index)
	var collision_shape : CollisionShape3D = CollisionShape3D.new()
	collision_shape.name = "CollisionShape3D"
	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.extents = Vector3(.2,.2,.2)
	
	static_body.position = item.position
	static_body.add_child(collision_shape)
	static_body.add_child(item)
	
	static_body.rotate(Vector3(1,0,0), deg_to_rad(90))
	static_body.rotate(Vector3(0,1,0), deg_to_rad(180))
	
	item.position = Vector3.ZERO
	return static_body

func load_items() -> void:
	player_inventory = SaveSystem.get_inventory()
	var index = 0
	for item in player_inventory:
		if player_inventory[item] == 0: continue
		var item_resource : Resource = SaveSystem.inventory_item_to_resource[item]
		var model : PackedScene = item_resource.model
		var instance : Node3D = model.instantiate()
		var static_body : ObjectViewerInteractable = create_clickable_item(instance, index)
		static_body.position = item_positions_grid[index]
		item_instances.push_back(static_body)
		print("Static body name: ", static_body.name)
		index += 1

func show_items() -> void:
	for item in item_instances:
		add_child(item)

func hide_items() -> void:
	for item in get_children():
		remove_child(item)
