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
const LIST_TYPE = {
	BLACKLIST = 1,
	WHITELIST = 2,
}

func is_of_type_in_array(node : Node, types : Array[Variant]):
	for type in types:
		if is_instance_of(node, type):
			return true
	return false
	
func get_children_exclusive(
	node:Node, 
	type_list : Array[Variant] = [], 
	list_type : int = LIST_TYPE.BLACKLIST
) -> Array[Node]:
	var children : Array[Node] = []
	for child : Node in node.get_children():
		var in_type_list : bool = is_of_type_in_array(child, type_list)
		if (
			(!in_type_list and list_type == LIST_TYPE.BLACKLIST) #Not on blacklist
			or (in_type_list and list_type == LIST_TYPE.WHITELIST) #On whitelist
		):
			children.append(child)	
	return children

func get_descendants(
	node:Node, 
	type_list : Array[Variant] = [], 
	list_type : int = LIST_TYPE.BLACKLIST
) -> Array[Node]: #recursive
	var descendants : Array[Node] = []
	for child in node.get_children():
		var in_type_list : bool = is_of_type_in_array(child, type_list)
		#print(node.name + " | In type list: ", in_type_list,  " and ", exclude)
		if (
			(!in_type_list and list_type == LIST_TYPE.BLACKLIST) #Not on blacklist
			or (in_type_list and list_type == LIST_TYPE.WHITELIST) #On whitelist
		):
			descendants.append(child)
		descendants.append_array(get_descendants(child, type_list))
	return descendants
	
func calculate_node_aabb(node3d : Node3D) -> AABB:
	var visual_nodes : Array[Node] = node3d.find_children("*", "VisualInstance3D", true, false)
	if node3d is VisualInstance3D:
		visual_nodes.push_back(node3d)
	assert(!visual_nodes.is_empty(), "There are no visual nodes in scene: " + node3d.name + "!")
	var aabb : AABB = visual_nodes[0].global_transform * visual_nodes[0].get_aabb()
	for node : Node in visual_nodes:
		if (node == visual_nodes[0] or 
		!(node is VisualInstance3D) or 
		(node is Light3D) or
		node.name == "PlayerCameraLocation" or
		node.name == "Lights"
		): continue
		var node_aabb : AABB = node.get_aabb()
		var global_aabb : AABB = node.global_transform * node_aabb
		aabb = aabb.merge(global_aabb)
		
	return aabb
	
func dict_to_string(dict:Dictionary) -> String:
	var str := ""
	for key in dict:
		str = str + "[color=red]" + key + "[/color]: " + str(dict[key]) + "\n\n"
		
	return str
