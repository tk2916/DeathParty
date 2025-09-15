class_name CharacterResource extends DefaultResource

@export var character_location_index : Globals.CHARACTER_LOCATIONS_ENUM = Globals.CHARACTER_LOCATIONS_ENUM.Everywhere

@export var image_full : CompressedTexture2D
@export var image_polaroid : CompressedTexture2D
@export var image_polaroid_popout : CompressedTexture2D
@export var name_color : String
@export var text_color : String

@export var character_notes : Array[String]
@export var character_description : String

@export var image_profile : CompressedTexture2D
@export var profile_tag : String = "@profiletag123"
@export var profile_quote : String = "inspirational quote goes here."
@export var profile_join_date : String = "Month 8, 20XX"
@export var profile_friends : int = 359

#CHATS
var upcoming_chats : Array[JSON] = []
@export var default_chat : JSON

signal unread(tf:bool)
signal location_changed
signal interaction_ended

var character_location : String:
	get: return Globals.get_character_location(character_location_index)

var first_chat: JSON:
	get:
		if upcoming_chats.is_empty():
			return null
		else:
			return upcoming_chats.front()

func chat_already_loaded(file : JSON) -> bool:
	for chat : JSON in upcoming_chats:
		if chat.resource_path == file.resource_path:
			return true
	return false

func load_chat(json : JSON) -> void:
	if chat_already_loaded(json): return
	upcoming_chats.push_back(json)
	unread.emit(true)

func set_default_chat(json : JSON) -> void:
	default_chat = json
	
func print_all_chats() -> void:
	print(name, "'s chats-------")
	for chat : JSON in upcoming_chats:
		print("Chat: ", chat, chat.resource_path)
	print("------")
	
func start_chat() -> void:
	#print_all_chats()
	if first_chat == null:
		if default_chat:
			DialogueSystem.from_character(self, default_chat)
	else:
		DialogueSystem.from_character(self, first_chat)
		
func end_chat() -> void:
	print("Ended chat with ", name, first_chat)
	upcoming_chats.pop_front()
	interaction_ended.emit()
	
func has_chats() -> bool:
	if default_chat or first_chat != null:
		return true
	else:
		return false
		
func change_location(location : String) -> void:
	#character_location = location
	for i : int in range(Globals.CHARACTER_LOCATIONS.size()):
		if Globals.CHARACTER_LOCATIONS[i] == location:
			character_location_index = i as Globals.CHARACTER_LOCATIONS_ENUM
			break
	location_changed.emit()
	
