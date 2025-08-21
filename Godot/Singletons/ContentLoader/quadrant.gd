class_name Quadrant

var aabb : AABB
var loadable_objects : Array[InteractableData]
var active : bool = false

func _init(origin : Vector3, size : Vector3) -> void:
	aabb = AABB(origin, size)
	
func set_active(parent_scene : Node3D, _active : bool) -> void:
	if _active == active: return #no change
	active = _active
	for obj : InteractableData in loadable_objects:
		if active:
			obj.load_in(parent_scene)
		else:
			obj.offload()
	
func intersects_interactable(data:InteractableData) -> bool:
	return intersects(data.aabb)

func intersects(aabb2:AABB):
	return aabb.intersects(aabb2)

func add_interactable(data:InteractableData) -> bool:
	if intersects_interactable(data):
		loadable_objects.push_back(data)
		return true
	else:
		return false
