class_name NPCData extends SceneObject

var npc : NPC
var character_resource : CharacterResource

var default_dialogue : JSON #plays every time if no other files
var starter_dialogue : JSON #one-pff file to start

func _init(
	_scene : LoadableScene,
	_instance : NPC,
	_parent_node : GameObject,
) -> void:
	super(
	_scene, 
	_instance,
	_parent_node
	)
	#print("New npc: ", _instance.name)
	npc = instance as NPC
	default_dialogue = npc.default_json
	starter_dialogue = npc.starter_json
	
	character_resource = npc.character_resource
		
	save_properties()

func load_in() -> Node3D:
	await super()
	npc = instance as NPC
	load_properties()
	return instance

func on_location_change() -> void:
	#print("CHARACTER LOCATION: ", character_resource.character_location)
	#toggled prevents this object from being loaded on scene load
	var character_location = character_resource.character_location
	if character_location == "Everywhere" or character_location == scene.name:
		toggled = true
		if scene.active:
			self.load_in()
	else:
		toggled = false
		if scene.active:
			self.offload()

func on_chat_ended() -> void:
	if npc:
		npc.on_in_range(true)

func save_properties() -> void:
	if character_resource:
		character_resource.location_changed.connect(on_location_change)
		character_resource.interaction_ended.connect(on_chat_ended)
		on_location_change()

func load_properties() -> void:
	if character_resource:
		print("Loading in NPC: ", name, " with ", starter_dialogue, " and ", default_dialogue, " and ", character_resource.image_polaroid)
		if starter_dialogue:
			character_resource.load_chat(starter_dialogue)
			starter_dialogue = null #only a one-off
		if default_dialogue:
			character_resource.set_default_chat(default_dialogue)
