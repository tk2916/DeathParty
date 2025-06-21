extends Resource

@export var name : String
@export var image : CompressedTexture2D
var unread_status : bool = false
var upcoming_chats : Array[JSON] = []
var past_chats : Array[Dictionary]
var last_message_timestamp : float

var chat_in_progress : bool = false
var last_ink_hierarchy : Array = []

func save_chat(array : Array[Dictionary]):
	past_chats = array
	
func load_past_chats(parent : Node):
	pass
	
func load_chat(json : JSON):
	print("Loaded chat")
	upcoming_chats.push_back(json)
	unread_status = true
	last_message_timestamp = SaveSystem.get_key("time")
	
func start_chat():
	var new_json : JSON = upcoming_chats.front()
	if new_json == null:
		chat_in_progress = false
		return
	if chat_in_progress:
		print("RESUMING CHAT: ", last_ink_hierarchy)
		DialogueSystem.from_JSON(new_json, last_ink_hierarchy) #load last hierarchy to resume chat
	else:
		DialogueSystem.from_JSON(new_json)
	chat_in_progress = true
	
func pause_chat():
	
	if chat_in_progress:
		#save current Ink hierarchy
		last_ink_hierarchy = Ink.hierarchy
		#last_ink_hierarchy[last_ink_hierarchy.size()-1] -= 1 #go one index before
		print("Paused chat: ", last_ink_hierarchy)

func end_chat():
	print("Ended chat")
	upcoming_chats.pop_front() #get it off the list
	chat_in_progress = false
	if upcoming_chats.size() == 0: unread_status = false
	
