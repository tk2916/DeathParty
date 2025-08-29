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
	npc = instance as NPC
	character_resource = npc.character_resource
	on_location_change()
	save_properties()

func load_in() -> Node3D:
	print("Loading in NPC: ", name, " at ", character_resource.character_location, " vs ", scene.name)
	#if character_resource and character_resource.character_location != scene.name:
		#return
	await super()
	npc = instance as NPC
	load_properties()
	return instance

func on_location_change() -> void:
	if character_resource == null: return
	if character_resource.character_location == "" or character_resource.character_location == scene.name:
		toggled = true
		if scene.active:
			self.load_in()
	else:
		toggled = false
		if scene.active:
			self.offload()

func save_properties():
	pass

func load_properties():
	pass
