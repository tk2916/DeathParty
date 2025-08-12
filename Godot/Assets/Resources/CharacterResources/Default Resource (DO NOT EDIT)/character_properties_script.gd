class_name CharacterResource extends Resource

@export var name : String
@export var image_full : CompressedTexture2D
@export var image_torso : CompressedTexture2D
@export var name_color : String
@export var text_color : String

@export var character_notes : Array[String]
@export var character_description : String

@export var profile_image : CompressedTexture2D
@export var profile_tag : String = "@profiletag123"
@export var profile_quote : String = "inspirational quote goes here."
@export var profile_join_date : String = "Month 8, 20XX"
@export var profile_friends : int = 359

#CHATS
var upcoming_chats : Array[JSON] = []
@export var default_chat : JSON

var ink_resource = load("res://Singletons/InkInterpreter/ink_interpret_resource.tres")

signal unread

func chat_already_loaded(file : JSON):
	for chat : JSON in upcoming_chats:
		if chat.resource_path == file.resource_path:
			return true
	return false

func load_chat(json : JSON) -> void:
	print("Loading chat: ", json, " ", name, " id: ", get_instance_id())
	if chat_already_loaded(json): return
	upcoming_chats.push_back(json)
	print("Loaded chat: ", name, " | ", upcoming_chats.size(), " | ", upcoming_chats.front())
	unread.emit(true)
	
func print_all_chats():
	print(name, "'s chats-------")
	for chat : JSON in upcoming_chats:
		print("Chat: ", chat, chat.resource_path)
	print("------")
	
func start_chat() -> void:
	print("Starting chat, ", name, " | id: ",  get_instance_id())
	print_all_chats()
	print("Total chats: ", self.upcoming_chats.size(), self.upcoming_chats.front())
	var new_json : JSON = self.upcoming_chats.front()
	print("New json: ", new_json)
	if new_json == null:
		if default_chat:
			DialogueSystem.from_character(self, default_chat)
	else:
		DialogueSystem.from_character(self, new_json)
		
func end_chat() -> void:
	print("Ending chat: ", name)
	upcoming_chats.pop_front()
