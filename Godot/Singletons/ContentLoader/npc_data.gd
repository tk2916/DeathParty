class_name NPCData extends SceneObject

var npc : NPC
var character_resource : CharacterResource

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
	character_resource = npc.character_resource
	if character_resource:
		character_resource.location_changed.connect(on_location_change)
		character_resource.interaction_ended.connect(on_chat_ended)
		on_location_change()
	save_properties()

func load_in() -> Node3D:
	if character_resource:
		print("Loading in NPC: ", name, " at ", character_resource.character_location, " vs ", scene.name)
	#if character_resource and character_resource.character_location != scene.name:
		#return
	await super()
	npc = instance as NPC
	load_properties()
	return instance

func on_location_change() -> void:
	#print("CHARACTER LOCATION: ", character_resource.character_location)
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

func save_properties():
	pass

func load_properties():
	pass
