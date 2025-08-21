class_name InteractableData

var file : PackedScene
var position : Vector3
var aabb : AABB
var interactable : Interactable = null
var parent_scene : Node3D = null

func _init(_file : PackedScene, _position : Vector3, _aabb : AABB) -> void:
	print("Initiating interactable data for : ", file.resource_path)
	file = _file
	position = _position
	aabb = _aabb

func load_in(_parent_scene : Node3D):
	parent_scene = _parent_scene
	interactable = file.instantiate()
	interactable.position = position
	
	parent_scene.add_child.call_deferred(interactable)

func offload():
	if parent_scene and interactable:
		parent_scene.remove_child.call_deferred(interactable)
		interactable.queue_free()
