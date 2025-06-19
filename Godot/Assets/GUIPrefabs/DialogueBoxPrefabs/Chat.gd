extends Resource

@export var name : String
@export var image : CompressedTexture2D
var unread_status : bool = false
var upcoming_chats : Array[JSON] = []
var past_chats : Array[Dictionary]
var last_message_timestamp : float

func save_chat(array : Array[Dictionary]):
	past_chats = array
	
func load_past_chats(parent : Node):
	pass
	
func load_chat(json : JSON):
	upcoming_chats.push_back(json)
	unread_status = true
	last_message_timestamp = SaveSystem.get_key("time")
	
func start_chat():
	var new_json : JSON = upcoming_chats.pop_front()
	if new_json == null:
		print("No chats left!")
		return
	if upcoming_chats.size() == 0: unread_status = false
	DialogueSystem.from_JSON(new_json)
	
