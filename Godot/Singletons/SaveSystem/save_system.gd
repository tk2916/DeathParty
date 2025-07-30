extends Node

const PLAYER_DATA_FILE_PATH = "res://Singletons/SaveSystem/player_data.tres"

var player_data_resource:Resource = load(PLAYER_DATA_FILE_PATH)
var player_data : Dictionary

#DIRECTORIES TO LOAD
const TASKS_FILE_PATH : String = "res://Assets/Resources/TaskResources/"
const CHARACTER_FILE_PATH : String = "res://Assets/Resources/CharacterResources/"
const PHONE_CHATS_FILE_PATH : String = "res://Assets/GUIPrefabs/DialogueBoxPrefabs/MessageAppAssets/ChatResources/"
const INVENTORY_ITEMS_FILE_PATH : String = "res://Assets/Resources/InventoryItemResources/"

const default_inventory_item_resource : InventoryItemResource = preload("res://Assets/Resources/InventoryItemResources/Default Resource (DO NOT EDIT)/inventory_item_properties.tres")

var task_to_resource : Dictionary[String, TaskResource] = {}
var character_to_resource : Dictionary[String, CharacterResource]
var phone_chat_to_resource : Dictionary[String, ChatResource]
var inventory_item_to_resource : Dictionary[String, InventoryItemResource]

'''
EVERYTHING WILL BE ACTUALLY SAVED WITHIN THE player_data DICTIONARY
The resource is basically for type-declaring purposes.
Everything is in the dictionary so Ink can access it too.
'''

signal time_changed
signal stats_changed
signal inventory_changed
signal tasks_changed
signal loaded

func _init() -> void:
	#Transfer all regular variables over to VariableDict
	var property_list : Array = player_data_resource.get_property_list()
	for n in range(9, property_list.size()): # gets variables listed in Resource
		var item : String = property_list[n].name # gets variable name
		if item == "VariableDict":
			continue
		if !player_data_resource["VariableDict"].has(item):
			player_data_resource["VariableDict"][item] = player_data_resource[item] #add if not already defined (from pervious save)
	player_data = player_data_resource["VariableDict"]
	
	load_directory_into_dictionary(TASKS_FILE_PATH, task_to_resource)
	load_directory_into_dictionary(CHARACTER_FILE_PATH, character_to_resource)
	load_directory_into_dictionary(PHONE_CHATS_FILE_PATH, phone_chat_to_resource)
	load_directory_into_dictionary(INVENTORY_ITEMS_FILE_PATH, inventory_item_to_resource)
	
	load_inventory()
	loaded.emit()
	
func load_directory_into_dictionary(address : String, dict:Dictionary) -> void:
	var dir : DirAccess = DirAccess.open(address)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	if dir:
		while file_name != "":
			if !dir.current_is_dir():
				var file = load(address + file_name)
				if file == null: break
				dict[file.name] = file
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the directory " + address)

func create_new_item(name:String, description:String, node:Node3D) -> void:
	if key_exists(name):
		print("Item ", name, " already exists!")
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
	
	var resource_save_path : String = INVENTORY_ITEMS_FILE_PATH + name + ".tres"
	ResourceSaver.save(resource, resource_save_path)
	inventory_item_to_resource[name] = load(resource_save_path)
	player_data["inventory"][name] = 0

func load_inventory() -> void: #Make sure player has an entry for each possible item
	#if player_data["inventory"].size() != player_data_resource["possible_items"].size():
	#adding new items
	print("Loading inventory: ", inventory_item_to_resource)
	for item in inventory_item_to_resource:#player_data_resource["possible_items"]:
		if !player_data["journal_entries"].has(item):
			player_data["journal_entries"][item] = false
		if !player_data["inventory"].has(item):
			player_data["inventory"][item] = 0
	#removing old items that don't exist anymore
	for item in player_data["inventory"]:
		if !inventory_item_to_resource.has(item):#player_data_resource["possible_items"].has(item):
			player_data["inventory"][item] = 0
			if player_data["journal_entries"].has(item):
				player_data["journal_entries"].erase(item)

#TYPE SAFETY
func key_exists(key:String) -> bool: # returns whether key exists
	return player_data.has(key)

func key_exists_assert(key:String) -> void: # returns location of key & errors if it doesn't exist
	assert(key_exists(key), "ERROR: invalid key '" + key + "'. Check your spelling!")

func key_is_type(key:String, type:int) -> void: # errors if types don't match (passing type enum)
	key_exists_assert(key)
	assert(typeof(player_data[key])==type, "ERROR: " + key + " not of type " + str(type) +
			"\nSee https://docs.godotengine.org/en/3.2/classes/class_@globalscope.html#enum-globalscope-variant-type")

func match_type(key:String, value) -> void: # errors if types don't match (passing new value)
	key_is_type(key, typeof(value))
	
##QUICK-ACCESS VALUES
func get_time() -> float:
	return get_key("time")

func get_time_string() -> String:
	return parse_time(get_time())

#EDITING
func get_key(key:String):
	key_exists_assert(key)
	return player_data[key]

func set_key(key:String, value) -> void:
	if key_exists(key):
		match_type(key, value) # asserts that they are of matching types
	player_data[key] = value
	if key == "time":
		time_changed.emit(value)
	else:
		stats_changed.emit(key, value)
	
func increment(key:String) -> void:
	set_key(key, player_data[key]+1) #will also emit signal

func decrement(key:String) -> void:
	set_key(key, player_data[key]-1)

#INVENTORY
func item_exists(item:String) -> void:
	assert(player_data["inventory"].has(item), "ERROR: no such item '" + item + "'. Check your spelling!")
	
func add_item(item:String) -> void:
	item_exists(item)
	player_data["inventory"][item] += 1
	inventory_changed.emit("add", item)

func remove_item(item:String) -> bool: #returns 1 if successful, 0 if there aren't any left
	item_exists(item)
	if player_data["inventory"][item] > 0:
		player_data["inventory"][item] -= 1
		inventory_changed.emit("remove", item)
		return true
	else:
		return false
		
func item_count(item:String) -> int:
	item_exists(item)
	return player_data["inventory"][item]

func get_inventory() -> Dictionary:
	return player_data["inventory"]
	
#TASKS
func task_exists(item:String) -> TaskResource:
	assert(task_to_resource.has(item), "ERROR: no such task '" + item + "'. Check your spelling!")
	return task_to_resource[item]
	
func add_task(item:String) -> void:
	print("Added task: ", item)
	task_exists(item)
	player_data["tasks"].push_back(item)
	tasks_changed.emit("add", item)

func complete_task(item:String) -> void: #returns 1 if successful, 0 if there aren't any left
	task_exists(item)
	tasks_changed.emit("complete", item)
	
#JOURNAL ENTRIES
func is_journal_entry_active(entry_name:String) -> bool:
	return player_data["journal_entries"][entry_name]

func set_journal_entry(entry_name:String, active:bool) -> void:
	player_data["journal_entries"][entry_name] = active

#SAVING
func save_data() -> void:
	var error = ResourceSaver.save(player_data_resource, PLAYER_DATA_FILE_PATH)
	if error:
		print("Error saving resource:", error)
	else:
		print("Resource saved successfully!")
		
#PARSE TIME
func parse_time(value : float) -> String:
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
