extends Node

func find_first_child_of_class(item : Node, type : Variant):
	for child in item.get_children():
		if is_instance_of(child, type):
			return child
	for child in item.get_children():
		var result = find_first_child_of_class(child, type)
		if (result != null):
			return result 
	return null

func get_collision_shape_aabb(collision_shape : CollisionShape3D):
	var shape : BoxShape3D = collision_shape.shape
	var aabb : AABB = AABB(-shape.size / 2.0, shape.size)
	aabb = collision_shape.global_transform * aabb
	return aabb
