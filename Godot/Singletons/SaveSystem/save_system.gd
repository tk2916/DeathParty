extends Node

enum SaveSlots {
	ONE,
	TWO,
	THREE,
}

var active_save_slot : SaveSlots
var active_save_file : SaveFile
var player_data : PlayerData

##START DATA
const DIRECTORIES : Dictionary[String, String] = {
	TASKS = "res://Singletons/SaveSystem/DefaultResources/TaskResources/",
	CHARACTERS = "res://Singletons/SaveSystem/DefaultResources/CharacterResources/",
	PHONE_CHATS = "res://Singletons/SaveSystem/DefaultResources/ChatResources/",
	INVENTORY_ITEMS = "res://Singletons/SaveSystem/DefaultResources/InventoryItemResources/",
	
}
const SLOT_TO_PATH : Dictionary[SaveSlots, String] = {
	SaveSlots.ONE: "Singletons/SaveSystem/SaveFiles/File1/save_file.tres",
	SaveSlots.TWO: "Singletons/SaveSystem/SaveFiles/File2/save_file.tres",
	SaveSlots.THREE: "Singletons/SaveSystem/SaveFiles/File3/save_file.tres",
}
##END DATA

#For creating new save files
const blank_save_file : SaveFile = preload("res://Singletons/SaveSystem/DefaultResources/save_file.tres")
#For creating new inventory items at runtime (e.g. taking polaroids)
const default_inventory_item_resource : InventoryItemResource = preload("res://Singletons/SaveSystem/DefaultResources/InventoryItemResources/Default Resource (DO NOT EDIT)/inventory_item_properties.tres")

signal time_changed
signal stats_changed
signal inventory_changed(addremove : String, item : InventoryItemResource)
signal tasks_changed
signal loaded

func _init() -> void:
	#Check if there is an existing save file (if not, a new one will be created at SaveSlots.ONE)
	if FileAccess.file_exists(SLOT_TO_PATH[SaveSlots.ONE]):
		active_save_slot = SaveSlots.ONE
	elif FileAccess.file_exists(SLOT_TO_PATH[SaveSlots.TWO]):
		active_save_slot = SaveSlots.TWO
	elif FileAccess.file_exists(SLOT_TO_PATH[SaveSlots.THREE]):
		active_save_slot = SaveSlots.THREE
	else:
		active_save_slot = SaveSlots.ONE

	load_active_save_file()

func update_save_file(file : SaveFile) -> void:
	load_into_dictionary(DIRECTORIES.TASKS, file.tasks)
	load_into_dictionary(DIRECTORIES.CHARACTERS, file.characters)
	load_into_dictionary(DIRECTORIES.PHONE_CHATS, file.phone_chats)
	load_into_dictionary(DIRECTORIES.INVENTORY_ITEMS, file.inventory_items)

#SAVE/LOAD
func save_data() -> void:
	var error : Error = ResourceSaver.save(active_save_file, SLOT_TO_PATH[active_save_slot])
	if error:
		print("Error saving resource:", error)
	else:
		print("Resource saved successfully!")

func save_data_to_slot(slot : SaveSlots) -> void:
	var slot_path : String = SLOT_TO_PATH[slot]
	ResourceSaver.save(active_save_file, slot_path)

func load_file_from_slot(slot : SaveSlots) -> void:
	active_save_slot = slot
	load_active_save_file()

func load_active_save_file() -> void:
	if !FileAccess.file_exists(SLOT_TO_PATH[active_save_slot]):
		## if no file found, create one
		var clone : SaveFile = blank_save_file.duplicate(true)
		ResourceSaver.save(clone, SLOT_TO_PATH[active_save_slot])

	active_save_file = ResourceLoader.load(SLOT_TO_PATH[active_save_slot])
	update_save_file(active_save_file)
	player_data = active_save_file.player_data
	load_inventory()
	loaded.emit()
##END SAVE/LOAD

func load_into_dictionary(address : String, dict:Dictionary) -> void:
	## To clear out any extra keys (such as old items that don't exist anymore),
	## keep track of the mentioned keys here and check against dict afterward
	var dict_keys : Array[String] = []
	var dir : DirAccess = DirAccess.open(address)
	dir.list_dir_begin()
	var file_name : String = dir.get_next()
	if dir:
		while file_name != "":
			if !dir.current_is_dir():
				var file : Resource = load(address + file_name)
				if file == null: continue
				var filename : String = file.name
				if address == DIRECTORIES.INVENTORY_ITEMS:
					print("Found inventory item: ", filename)
				dict_keys.push_back(filename)
				if !dict.has(filename):
					dict[filename] = file.duplicate(true)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the directory " + address)
	
	#remove old entries
	for key : String in dict:
		if !(key in dict_keys):
			dict.erase(key)

## New inventory items (like snapped polaroids)
func create_new_item(item_name:String, description:String, node:Node3D) -> void:
	if key_exists(item_name):
		print("Item ", item_name, " already exists!")
		return
	#save node as scene
	var scene_save_path : String = "res://Assets/props/inventory_items/" + name + ".tscn"
	if !FileAccess.file_exists(scene_save_path):
		var scene : PackedScene = PackedScene.new()
		scene.pack(node)
		ResourceSaver.save(scene, scene_save_path)
	var saved_scene : PackedScene = load(scene_save_path)
	#assign scene to new resource
	var resource : InventoryItemResource = default_inventory_item_resource.duplicate()
	resource.name = name
	resource.description = description
	resource.model = saved_scene
	
	var resource_save_path : String = DIRECTORIES.INVENTORY_ITEMS + name + ".tres"
	ResourceSaver.save(resource, resource_save_path)
	active_save_file.inventory_items[name] = load(resource_save_path)
	active_save_file.inventory_items[name].amount_owned = 0

func load_inventory() -> void: 
	#Make sure player has an entry for each possible item
	#add in any new items
	for item_name : String in active_save_file.inventory_items:
		if !player_data.journal_entries.has(item_name):
			player_data.journal_entries[item_name] = false

#TYPE SAFETY
func key_exists(key:String) -> bool: # returns whether key exists
	return player_data.variable_dict.has(key)

func key_exists_assert(key:String) -> void: # returns location of key & errors if it doesn't exist
	assert(key_exists(key), "ERROR: invalid key '" + key + "'. Check your spelling!")

func key_is_type(key:String, type:int) -> void: # errors if types don't match (passing type enum)
	key_exists_assert(key)
	assert(typeof(player_data.variable_dict[key])==type, "ERROR: " + key + " not of type " + str(type))

func match_type(key:String, value:Variant) -> void: # errors if types don't match (passing new value)
	key_is_type(key, typeof(value))

#Mapping names to resources
func get_character(char_name : String) -> CharacterResource:
	if !active_save_file.characters.has(char_name):
		return null
	return active_save_file.characters[char_name]

func get_phone_chat(phone_chat_name : String) -> ChatResource:
	if !active_save_file.phone_chats.has(phone_chat_name):
		return null
	return active_save_file.phone_chats[phone_chat_name]

func get_inventory_item(item_name : String) -> InventoryItemResource:
	if !active_save_file.inventory_items.has(item_name):
		return null
	return active_save_file.inventory_items[item_name]

##QUICK-ACCESS VALUES
func get_time() -> float:
	return get_key("time")

func get_time_string(include_ampm:bool = true) -> String:
	return parse_time(get_time(), include_ampm)

#EDITING
func get_key(key:String) ->  Variant:
	key_exists_assert(key)
	return player_data.variable_dict[key]

func set_key(key:String, value:Variant) -> void:
	if key_exists(key):
		match_type(key, value) # asserts that they are of matching types
	player_data.variable_dict[key] = value
	if key == "time":
		time_changed.emit(value)
	else:
		stats_changed.emit(key, value)
	
func increment(key:String) -> void:
	set_key(key, player_data.variable_dict[key]+1) #will also emit signal

func decrement(key:String) -> void:
	set_key(key, player_data.variable_dict[key]-1)

#INVENTORY
func item_exists(item_name:String) -> InventoryItemResource:
	assert(active_save_file.inventory_items.has(item_name), "ERROR: no such item '" + item_name + "'. Check your spelling!")
	return active_save_file.inventory_items[item_name]

func add_item(item_name:String) -> void:
	var item := item_exists(item_name)
	item.amount_owned += 1
	inventory_changed.emit("add", item)

func remove_item(item_name:String) -> bool: #returns 1 if successful, 0 if there aren't any left
	var item := item_exists(item_name)
	if item.amount_owned > 0:
		item.amount_owned -= 1
		inventory_changed.emit("remove", item)
		return true
	else:
		return false
		
func item_count(item_name:String) -> int:
	var item := item_exists(item_name)
	return item.amount_owned

func get_inventory() -> Dictionary[String, InventoryItemResource]:
	return active_save_file.inventory_items
	
#TASKS
func task_exists(item:String) -> TaskResource:
	assert(active_save_file.tasks.has(item), "ERROR: no such task '" + item + "'. Check your spelling!")
	return active_save_file.tasks[item]
	
func add_task(item:String) -> void:
	print("Added task: ", item)
	task_exists(item)
	player_data.tasks.push_back(item)
	tasks_changed.emit("add", item)

func complete_task(item:String) -> void: #returns 1 if successful, 0 if there aren't any left
	task_exists(item)
	tasks_changed.emit("complete", item)
	
#JOURNAL ENTRIES
func is_journal_entry_active(entry_name:String) -> bool:
	return player_data.journal_entries[entry_name]

func set_journal_entry(entry_name:String, active:bool) -> void:
	player_data.journal_entries[entry_name] = active
		
#PARSE TIME
func parse_time(value : float, include_ampm : bool = true) -> String:
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
	
	if include_ampm:
		return str(hour) + ":" + mins_string + am_pm
	else:
		return str(hour) + ":" + mins_string
