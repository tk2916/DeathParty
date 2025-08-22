class_name Quadrant

var id : int
var aabb : AABB
var loadable_objects : Array[InteractableData]
var active : bool = false

func _init(_id : int, origin : Vector3, size : Vector3) -> void:
	id = _id
	aabb = AABB(origin, size)
	
func set_active(parent_scene : Node3D, _active : bool) -> void:
	if _active == active: return #no change
	print("Set quadrant active: ", id, " | toggle: ", _active)
	active = _active
	for obj : InteractableData in loadable_objects:
		#print("Object in quadrant ", id, ": ", obj.name)
		if active and obj.active == false:
			obj.load_in(parent_scene)
		elif !active and obj.active == true:
			obj.offload()
	
func intersects_interactable(data:InteractableData) -> bool:
	return intersects(data.aabb)

func intersects(aabb2:AABB):
	return aabb.intersects(aabb2)

func add_interactable(data:InteractableData) -> bool:
	#if data.quadrant_id != -1: return false #already assigned
	if intersects_interactable(data):
		#data.quadrant_id = self.id
		loadable_objects.push_back(data)
		return true
	else:
		return false
