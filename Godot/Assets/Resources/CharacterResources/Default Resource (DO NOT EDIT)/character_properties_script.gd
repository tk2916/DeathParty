extends Resource

@export var name : String
@export var image_full : CompressedTexture2D
@export var image_torso : CompressedTexture2D
@export var name_color : String
@export var text_color : String

@export var character_notes : Array[String]
@export var character_description : String

#CHATS
var upcoming_chats : Array[JSON] = []
@export var default_chat : JSON

var ink_resource = load("res://Singletons/InkInterpreter/ink_interpret_resource.tres")

signal unread

func load_chat(json : JSON):
	upcoming_chats.push_back(json)
	unread.emit(true)
	
func start_chat():
	var new_json : JSON = upcoming_chats.front()
	if new_json == null:
		if default_chat:
			DialogueSystem.from_JSON(default_chat)
	else:
		DialogueSystem.from_JSON(new_json)
		
func end_chat():
	upcoming_chats.pop_front()
