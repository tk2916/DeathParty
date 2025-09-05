class_name SaveFile extends Resource

@export var player_data : PlayerData
@export var tasks : Dictionary[String, TaskResource] = {}
@export var characters : Dictionary[String, CharacterResource] = {}
@export var phone_chats : Dictionary[String, ChatResource] = {}
@export var inventory_items : Dictionary[String, InventoryItemResource] = {}