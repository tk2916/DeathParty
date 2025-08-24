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

func print_array(arr:Array):
	print("Printing array ", arr, ": ")
	for item in arr:
		print(item)
	print("End array")

##get descendants
func is_of_type_in_array(node : Node, types : Array[Variant]):
	for type in types:
		if is_instance_of(node, type):
			return true
	return false

func get_descendants(node:Node, type_list : Array[Variant] = [], exclude : bool = true) -> Array[Node]: #recursive
	var descendants : Array[Node] = []
	for child in node.get_children():
		var in_type_list : bool = is_of_type_in_array(child, type_list)
		#print(node.name + " | In type list: ", in_type_list,  " and ", exclude)
		if (
			(!in_type_list and exclude) #Not on blacklist
			or (in_type_list and !exclude) #On whitelist
		):
			descendants.append(child)
			#print("Appended ", child.name)
		descendants.append_array(get_descendants(child, type_list))
	#print("Returning")
	return descendants
