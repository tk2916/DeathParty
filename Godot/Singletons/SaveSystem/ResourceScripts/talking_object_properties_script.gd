class_name TalkingObjectResource extends DefaultResource

#const JSONArray : Resource = preload("res://Singletons/SaveSystem/json_array.tres")

#CHATS
var upcoming_chats : Array[JSON] = []
var default_chat : JSON

## ORDER: Room-specific -> Everywhere
@export var default_chats : Dictionary[Globals.SCENES, JSON] = {}
@export var queue_chats : Dictionary[Globals.SCENES, JSONArray] = {}

signal unread(tf:bool)

func initialize() -> void:
	load_chats_for_room()
	ContentLoader.finished_loading.connect(load_chats_for_room)
	ContentLoader.switched_scene.connect(load_chats_for_room)

var first_chat: JSON:
	get:
		if upcoming_chats.is_empty():
			return null
		else:
			return upcoming_chats.front()

func load_chats_for_room() -> void:
	if ContentLoader.active_scene_enum == Globals.SCENES.Nowhere: return
	print("Loading chats for room ", Globals.get_scene_name(ContentLoader.active_scene_enum))
	default_chat = null
	upcoming_chats = []

	#set default chat
	var room : Globals.SCENES = ContentLoader.active_scene_enum
	if default_chats.has(room) and default_chats[room] != null:
		print("Got default chat for ", name)
		default_chat = default_chats[room]
	elif default_chats.has(Globals.SCENES.Everywhere) and default_chats[Globals.SCENES.Everywhere] != null:
		default_chat = default_chats[Globals.SCENES.Everywhere]

	#set queue chats
	if queue_chats.has(room) and not queue_chats[room].json_array.is_empty():
		upcoming_chats.append_array(queue_chats[room].json_array)
	if queue_chats.has(Globals.SCENES.Everywhere) and not queue_chats[Globals.SCENES.Everywhere].json_array.is_empty():
		upcoming_chats.append_array(queue_chats[Globals.SCENES.Everywhere].json_array)

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
	print("Started chat with ", name, "!")
	#print_all_chats()
	if first_chat == null:
		print("First chat null")
		if default_chat:
			print("Yes default chat")
			DialogueSystem.from_character(self, default_chat)
	else:
		DialogueSystem.from_character(self, first_chat)
		
func end_chat(_current_conversation : Array[InkLineInfo] = []) -> void:
	print("Ended chat with ", name)
	upcoming_chats.pop_front()
	if queue_chats.has(ContentLoader.active_scene_enum):
		var scene_chats : Array[JSON] = queue_chats[ContentLoader.active_scene_enum].json_array
		scene_chats.pop_front()
	
func has_chats() -> bool:
	if default_chat or first_chat != null:
		return true
	else:
		return false
