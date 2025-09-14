extends Node

## Cache
var ink_tree_cache : Dictionary[String, InkTree] = {}
var most_recently_used : Array[String] = []
const CACHE_MAX : int 	= 4

var evaluation_stack : Array = []

## EVAL STACK FUNCTIONS
func pop() -> Variant:
	return evaluation_stack.pop_back()
func push(item : Variant) -> void:
	evaluation_stack.push_back(item)

## Global current address
var address : InkAddress

func from_JSON(json: JSON) -> void:
	var tree : InkTree = check_cache(json)
	var container : InkContainer = tree.containers["root"]
	#if tree.containers.has("PartyInvite"):
	#	print("PARTYINVITE CONTAINER: \n" + tree.containers["PartyInvite"].tostring())
	var index : int = 0
	address = InkAddress.new(tree, container, index)
	print("Start address: ", address.container.name, ", ", address.index)

func from_address(_address : InkAddress) -> void:
	address = _address

func check_cache(json : JSON) -> InkTree:
	var filepath : String = json.resource_path
	var tree : InkTree
	if ink_tree_cache.has(filepath):
		tree = ink_tree_cache[filepath]

		#update cache recency array
		var index : int = most_recently_used.find(filepath)
		most_recently_used.remove_at(index)
		most_recently_used.push_front(filepath)
	else:
		tree = InkParser.parse(json)
		add_new_to_cache(filepath, tree)

	return tree

func add_new_to_cache(filepath : String, tree : InkTree) -> void:
	most_recently_used.push_front(filepath) #most recently used tree gets pushed to front
	if most_recently_used.size() > CACHE_MAX:
		#delete extras from cache
		var to_be_deleted : String = most_recently_used.pop_back() #pop least recently used tree
		ink_tree_cache.erase(to_be_deleted)
	ink_tree_cache[filepath] = tree

func get_content() -> Array[InkNode]:
	#var current_path : String = current_address.container.path + str(current_address.index)
	var nodes : Array[InkNode] = address_to_node(address)
	address.index += 1

	var first_node : InkNode = nodes[0]
	
	if first_node is InkLineInfo:
		# one node in the array
		if first_node.is_visible():
			return nodes
	elif first_node is InkChoiceInfo:
		# multiple nodes in the array
		var export_nodes : Array[InkNode] = []
		for node : InkNode in nodes:
			if node.is_visible():
				export_nodes.push_back(node)
		return export_nodes
	elif first_node is InkRedirect:
		# one node in the array
		var redirect : InkRedirect = first_node
		address = redirect_path_to_address(address, redirect.redirect)
	elif first_node is InkContainer:
		address.container = first_node
		address.index = 0

	return get_content()

func make_choice(redirect_path : String) -> void:
	address = redirect_path_to_address(address, redirect_path)
	print("Made choice: ", address)

func get_first_message(json : JSON) -> InkLineInfo:
	var old_address : InkAddress = address

	var tree : InkTree = check_cache(json)
	address = InkAddress.new(tree, tree.containers["root"], 0)
	var first_message : Array[InkNode] = get_content()

	address = old_address
	return first_message[0]

func address_to_node(current_address : InkAddress) -> Array[InkNode]:
	print("------ GETTNG NODE at ", current_address.container.path + "." + str(current_address.index))
	var container : InkContainer = current_address.container
	var index : int = current_address.index
	if index < container.dialogue_lines.size():
		#print("------ Dialogue lines in order: ")
		#for line in container.dialogue_lines:
		#	print(line.tostring())
		print("Selected line: ", container.dialogue_lines[index].tostring())
		return [container.dialogue_lines[index]]
	else:
		print("Returning choices")
		var as_ink_nodes : Array[InkNode] = []
		#container.dialogue_choices as Array[InkNode]
		for choice : InkChoiceInfo in container.dialogue_choices:
			as_ink_nodes.push_back(choice)
		return as_ink_nodes

func redirect_path_to_address(current_address : InkAddress, path : String) -> InkAddress:
	print("Redirect path: ", path)
	var new_address : InkAddress = current_address.duplicate()

	var relative_path : bool = path[0] == "."
	var path_array : Array = Array(path.split('.'))

	var final_index : int = path_array.size()-1

	# Go up the parent tree
	if relative_path:
		var first_carat : bool = true #Skip first carat (just means the current container)
		for n in range(1, final_index): # exclude last element (redirect or index), skip first element (empty space)
			var item : String = path_array[n]
			if item == "^":
				if first_carat:
					first_carat = false
					continue
				else:
					new_address.container = new_address.container.parent_container # set address container to parent

		# Get index or redirect container within current container
		var last_path_element : String = path_array[final_index]
		if last_path_element.is_valid_int(): #then it is an index
			new_address.index = int(last_path_element)
		else: #then it is a redirect (sub-container)
			print("New container: ", new_address.container.name)
			new_address.container = new_address.container.redirects[last_path_element]
			new_address.index = 0

		return new_address
	else: # 0.c-1 (always starts with zero)
		var container_name : String = path_array[0]
		var new_container : InkContainer

		if container_name == "0":
			#sometimes it is 0.c-0 (from root redirect table), sometimes 0.8.s (from a sub-container)
			new_container = current_address.tree.containers["root"]
			for n in range(1, final_index+1):
				var item : String = path_array[n]
				if item.is_valid_int(): 
					#sub-container
					var sub_container : InkContainer = new_container.dialogue_lines[int(item)]
					new_container = sub_container
				else: 
					#redirect table container
					var redirect_table : Dictionary[String, InkContainer] = new_container.redirects
					new_container = redirect_table[item]
		else:
			#container is referenced by name
			#get container from tree (root)
			new_container = current_address.tree.containers[container_name]
			
		return InkAddress.new(current_address.tree, new_container, 0)
	
