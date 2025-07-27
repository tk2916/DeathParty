class_name ChatResource extends Resource

@export var name : String
@export var image : CompressedTexture2D
var upcoming_chats : Array[JSON] = []
var past_chats : Array[Dictionary]
var display_timestamp : float = 0.0
var display_message : String = ""

var chat_in_progress : bool = false
var last_ink_hierarchy : Array = []
var saved_ink_state : Resource

var ink_resource = load("res://Singletons/InkInterpreter/ink_interpret_resource.tres")

signal unread

func update_chat_info():
	if(upcoming_chats.front()):
		display_timestamp = SaveSystem.get_key("time")
		display_message = DialogueSystem.get_first_message(upcoming_chats.front()).text

func load_chat(json : JSON):
	upcoming_chats.push_back(json)
	update_chat_info()
	unread.emit(true)
	
func start_chat():
	if (saved_ink_state):
		print("Starting chat: ", name, " | ", saved_ink_state.hierarchy)
	else:
		print("No hierarchy starting chat: ", name)
	DialogueSystem.load_past_messages(past_chats) #load it even if there are no new messages so player can see old ones
	var new_json : JSON = upcoming_chats.front()
	if new_json == null:
		chat_in_progress = false
		return
	if chat_in_progress:
		print("Chat is in progress: ", name)
		DialogueSystem.from_JSON(new_json, saved_ink_state)#last_ink_hierarchy) #load last hierarchy to resume chat
	else:
		DialogueSystem.from_JSON(new_json)
	chat_in_progress = true
	
func pause_chat(current_conversation : Array[Dictionary]):
	if chat_in_progress: #ONLY if in progress or it will save the wrong messages
		#save added lines
		past_chats = current_conversation
		print(name, " is saving past chats as ", past_chats)
		#save current Ink hierarchy
		#last_ink_hierarchy = Ink.hierarchy
		saved_ink_state = ink_resource.duplicate(true) #saves current variables
		update_chat_info()

func end_chat(current_conversation):
	past_chats = current_conversation
	upcoming_chats.pop_front() #get it off the list
	chat_in_progress = false
	if upcoming_chats.size() == 0:
		unread.emit(false)
	
