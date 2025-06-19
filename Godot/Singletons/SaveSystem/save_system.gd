extends Node

const FILE_PATH = "res://Singletons/SaveSystem/player_data.tres"
var player_data:Resource = load(FILE_PATH)

#var locations : Array = []

signal stats_changed
signal inventory_changed
signal loaded

func _init() -> void:
	#locations[0] = player_data
	#locations[1] = player_data["VariableDict"]
	
	#Transfer all regular variables over to VariableDict
	var property_list : Array = player_data.get_property_list()
	for n in range(9, property_list.size()-1): # gets variables listed in Resource
		var item : String = property_list[n].name # gets variable name
		#print(item)
		if item == "VariableDict":
			continue
		if !player_data["VariableDict"].has(item):
			player_data["VariableDict"][item] = player_data[item] #add if not already defined (from pervious save)
	load_inventory()
	#print(player_data["name"], " | Inventory: ", player_data["inventory"])
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
func key_exists(key:String): # returns whether key exists
	return key in player_data["VariableDict"]

func key_exists_assert(key:String): # returns location of key & errors if it doesn't exist
	assert(key_exists(key), "ERROR: invalid key '" + key + "'. Check your spelling!")

func key_is_type(key:String, type:int): # errors if types don't match (passing type enum)
	key_exists_assert(key)
	assert(typeof(player_data["VariableDict"][key])==type, "ERROR: " + key + " not of type " + str(type) +
		"\nSee https://docs.godotengine.org/en/3.2/classes/class_@globalscope.html#enum-globalscope-variant-type")

func match_type(key:String, value): # errors if types don't match (passing new value)
	key_is_type(key, typeof(value))

#EDITING
func get_key(key:String):
	key_exists_assert(key)
	return player_data["VariableDict"][key]

func set_key(key:String, value):
	if key_exists(key):
		match_type(key, value) # asserts that they are of matching types
	player_data["VariableDict"][key] = value
	stats_changed.emit(key, value)
	
func increment(key:String):
	set_key(key, player_data["VariableDict"][key]+1) #will also emit signal

func decrement(key:String):
	set_key(key, player_data["VariableDict"][key]-1)

#INVENTORY
func item_exists(item:String):
	assert(player_data["inventory"].has(item), "ERROR: no such item '" + item + "'. Check your spelling!")
	
func add_item(item:String):
	item_exists(item)
	player_data["inventory"][item] += 1
	inventory_changed.emit("add", item)

func remove_item(item:String): #returns 1 if successful, 0 if there aren't any left
	item_exists(item)
	if player_data["inventory"][item] > 0:
		player_data["inventory"][item] -= 1
		inventory_changed.emit("remove", item)
		return true
	else:
		return false
		
func item_count(item:String):
	item_exists(item)
	return player_data["inventory"][item]

#SAVING
func save_data():
	var error = ResourceSaver.save(player_data, FILE_PATH)
	if error:
		print("Error saving resource:", error)
	else:
		print("Resource saved successfully!")
		
#PARSE TIME
func parse_time(value : float):
	var am_pm : String = " a.m."
	var hour : int = int(value)%24
	var minutes : int = int((value - hour)*60)%60 #isolate decimal
	var mins_string : String = str(minutes)
	if hour == 0:
		hour = 12
		am_pm = " a.m."
	elif hour > 12:
		hour -= 12
		am_pm = " p.m."
	
	if minutes == 0:
		mins_string = "00"
	elif minutes < 10:
		mins_string = "0"+mins_string
	
	return str(hour) + ":" + mins_string + am_pm
