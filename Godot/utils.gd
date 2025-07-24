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
