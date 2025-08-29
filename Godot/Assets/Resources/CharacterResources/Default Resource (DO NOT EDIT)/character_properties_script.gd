class_name CharacterResource extends Resource

@export var name : String
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

var ink_resource : InkResource = load("res://Singletons/InkInterpreter/ink_interpret_resource.tres")

signal unread(tf:bool)

func chat_already_loaded(file : JSON) -> bool:
	for chat : JSON in upcoming_chats:
		if chat.resource_path == file.resource_path:
			return true
	return false

func load_chat(json : JSON) -> void:
	if chat_already_loaded(json): return
	upcoming_chats.push_back(json)
	unread.emit(true)
	
func print_all_chats() -> void:
	print(name, "'s chats-------")
	for chat : JSON in upcoming_chats:
		print("Chat: ", chat, chat.resource_path)
	print("------")
	
func start_chat() -> void:
	print_all_chats()
	var new_json : JSON = self.upcoming_chats.front()
	if new_json == null:
		if default_chat:
			DialogueSystem.from_character(self, default_chat)
	else:
		DialogueSystem.from_character(self, new_json)
		
func end_chat() -> void:
	upcoming_chats.pop_front()
	
func has_chats() -> bool:
	if default_chat:
		return true
	elif upcoming_chats.size() > 0:
		return true
	else:
		return false
