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
		
	save_properties()
	scene.npc_dict[name] = self

func load_in() -> Node3D:
	await super()
	npc = instance as NPC
	load_properties()
	return instance

func on_location_change() -> void:
	#print("CHARACTER LOCATION: ", character_resource.character_location)
	#toggled prevents this object from being loaded on scene load
	var character_location : Globals.SCENES = character_resource.character_location
	if character_location == Globals.SCENES.Everywhere or character_location == scene.scene_enum:
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
	pass
