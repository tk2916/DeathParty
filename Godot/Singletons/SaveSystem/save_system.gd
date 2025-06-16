extends Node

const FILE_PATH = "res://Singletons/SaveSystem/player_data.tres"
var player_data:Resource = load(FILE_PATH)

signal stats_changed
signal inventory_changed
signal loaded

func _init() -> void:
	load_inventory()
	print(player_data["name"], " | Inventory: ", player_data["inventory"])
	loaded.emit()

func load_inventory(): #Make sure player has an entry for each possible item
	if player_data["inventory"].size() != player_data["possible_items"].size():
		#adding new items
		for item in player_data["possible_items"]:
			if !player_data["inventory"].has(item):
				player_data["inventory"][item] = 0
		#removing old items that don't exist anymore
		for item in player_data["inventory"]:
			if !player_data["possible_items"].has(item):
				player_data["inventory"][item] = 0

#TYPE SAFETY
func key_exists(key:String):
	assert(key in player_data, "ERROR: invalid key '" + key + "'. Check your spelling!")
	
func key_is_type(key:String, type:int):
	key_exists(key)
	assert(typeof(player_data[key])==type, "ERROR: " + key + " not of type " + str(type) +
		"\nSee https://docs.godotengine.org/en/3.2/classes/class_@globalscope.html#enum-globalscope-variant-type")

func match_type(key:String, value):
	key_is_type(key, typeof(value))
	
func item_exists(item:String):
	assert(player_data["inventory"].has(item), "ERROR: no such item '" + item + "'. Check your spelling!")

#EDITING
func edit(key:String, value):
	match_type(key, value)
	player_data[key] = value
	stats_changed.emit(key)
	
func increment(key:String):
	key_is_type(key, TYPE_INT)
	edit(key, player_data[key]+1) #will also emit signal

func decrement(key:String):
	key_is_type(key, TYPE_INT)
	edit(key, player_data[key]-1)

#INVENTORY
func add_item(item:String):
	item_exists(item)
	player_data["inventory"][item] += 1
	inventory_changed.emit("add", item)

func remove_item(item:String):
	item_exists(item)
	if player_data["inventory"][item] > 0:
		player_data["inventory"][item] -= 1
		inventory_changed.emit("remove", item)
	else:
		return "You don't have any more " + item + "s!"
		
func item_count(item:String):
	item_exists(item)
	return player_data["inventory"][item]

#INK VARIABLES
func set_variable(variable : String, new_value):
	player_data["variableDict"][variable] = new_value

func get_variable(variable : String):
	return player_data["variableDict"][variable]

func has_variable(variable : String):
	return player_data["variableDict"].has(variable)

#SAVING
func save_data():
	var error = ResourceSaver.save(player_data, FILE_PATH)
	if error:
		print("Error saving resource:", error)
	else:
		print("Resource saved successfully!")
