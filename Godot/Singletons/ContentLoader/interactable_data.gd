class_name InteractableData

var name : String
var file : PackedScene
var transform : Transform3D
var aabb : AABB
var interactable : Interactable = null
var parent_scene : Node3D = null
var quadrant_id : int = -1 #set by add_interactable() in Quadrant

func _init(_name : String, _file : PackedScene, _transform : Transform3D, _aabb : AABB) -> void:
	name = _name
	file = _file
	transform = _transform
	aabb = _aabb
	print("Initiated interactable data for : ", name, " | file: ", file)

func load_in(_parent_scene : Node3D):
	print("Loading in ", name)
	parent_scene = _parent_scene
	interactable = file.instantiate() as Interactable
	assert(interactable != null, name + " doesn't have the NPC/Interactable script attached to it in its base scene!")
	interactable.transform = transform
	
	parent_scene.add_child.call_deferred(interactable)

func offload():
	print("Offloading interactable ", name)
	if parent_scene and interactable:
		parent_scene.remove_child.call_deferred(interactable)
		interactable.queue_free()
