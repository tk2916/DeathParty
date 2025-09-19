extends Node

var json_dict : Dictionary #Dictionary from JSON file
var evaluation_mode : bool = false #Are we pushing/popping variables onto the stack?
var string_evaluation_mode : bool = false #Are we collecting choice text?
var evaluation_stack_items : Array = [] #Used for T/F calculations using player variables
var string_eval_stream : String = "" #Stores text for choices (text inside evaluation mode)
var last_speaker : String = "" #Inferred speaker

const HASH_F : String = char(35) + "f"
func hash_f_only(dict : Dictionary) -> bool:
	if dict.has(HASH_F) and dict.keys().size() == 1:
		return true
	else:
		return false

##EVAL STACK FUNCTIONS
func pop() -> Variant:
	return evaluation_stack_items.pop_back()
func push(item : Variant) -> void:
	evaluation_stack_items.push_back(item)

class InkParseContainer:
	var tree : InkTree
	var name : String
	var root : Array = []
	var path : String
	func _init(
		inktree : InkTree, 
		parent_container : InkContainer,
		container_name : String, 
		container_root : Array,
		_path : String = "",
		is_redirect : bool = false,
	) -> void:
		tree = inktree
		name = container_name
		root = container_root
		
		#var temp_containers : Array[InkParseContainer] = []
		# Find path
		if _path != "":
			path = _path
		elif parent_container:
			path = parent_container.path + "." + name
		else:
			path = "0"

		# Will automatically parent itself to parent_container if not null
		var new_ink_container : InkContainer = InkContainer.new(parent_container, name, path, [], is_redirect)
		
		#Find redirect table
		var last_element : Variant = root[root.size()-1]
		if last_element is Dictionary:
			var last_dict : Dictionary = last_element
			if !InkParser.hash_f_only(last_dict):
				#Then it is the redirect table
				for other_container_name : String in last_dict:
					if !(last_dict[other_container_name] is Array): continue
					var other_container : Array = last_dict[other_container_name]
					InkParseContainer.new( 
						null,
						new_ink_container, 
						other_container_name, 
						other_container,
						"",
						true,
					)

		# Assign contents
		var arr_index : int = 0
		for item : Variant in root:
			InkParser.classify_line(arr_index, new_ink_container, item)
			arr_index += 1

		# Add to InkTree if no parent container
		if !parent_container:
			tree.containers[name] = new_ink_container

func parse(file : JSON) -> InkTree:
	print("CONTAINER F PARSING -------------------------------")
	## Convert from JSON to dict
	var filepath : String = file.resource_path
	var json_as_text : String = FileAccess.get_file_as_string(filepath)
	json_dict = JSON.parse_string(json_as_text)

	var new_tree : InkTree = InkTree.new()

	##ROOT
	var root_container : Array = json_dict["root"][0]
	InkParseContainer.new(new_tree, null, "root", root_container)

	##OTHER CONTAINERS
	for other_container_name : String in json_dict["root"][2]:
		if other_container_name != HASH_F and json_dict["root"][2][other_container_name] is Array:
			var other_container : Array = json_dict["root"][2][other_container_name]
			InkParseContainer.new(new_tree, null, other_container_name, other_container)
	
	return new_tree

func match_eval_cmd(new_container : InkContainer, path : String, next:Variant) -> bool:
	var was_command : bool = true
	match (next):
		"ev":
			evaluation_mode = true
		"/ev":
			evaluation_mode = false
		"str":
			string_evaluation_mode = true
		"/str":
			string_evaluation_mode = false
		"end":
			InkLineInfo.new(
					new_container,
					path,
					"System",
					"end",
				)
		_:
			was_command = false
	return was_command

func classify_line(arr_index : int, new_container : InkContainer, next : Variant) -> void:
	var path : String = new_container.path + "." + str(arr_index)

	if match_eval_cmd(new_container, path, next): return #if it's a command

	# NESTING
	if next is Array: #means there is a branch condition (either a choice or something condition-based)
		#print("Going into array: ", hierarchy)
		var arr : Array = next
		InkParseContainer.new(
			null, # no InkTree b/c we want to parent it to current container
			new_container, # this container
			path, # name (anonymous bc it is not in a dictionary)
			arr, # array root
			path,
		)
		return

	if next is String:
		var next_str : String = next
		if next_str[0] == '^': #is string
			next_str = next_str.substr(1)
			if next_str.replace(" ", "").length() == 0: #if it is just empty space
				return
			if string_evaluation_mode: #string eval mode takes precedence
				string_eval_stream = string_eval_stream + next_str
			else:
				var line_info : InkLineInfo = break_up_dialogue(new_container, path, next_str) #returns {"speaker":char_name, "text":dialogue_text}
				# if line_info.parent_container:
				# 	print("InkLineInfo for str: ", line_info.text, " | parent: ", line_info.parent_container.name)
				if line_info.speaker == "ChoiceInfo":
					#Automatically pushes itself to choices array
					#no redirect path required because it is only used as flavor text to the choices UI
					InkChoiceInfo.new(new_container, path, line_info.text, "")
			return

	if evaluation_mode:
		#We don't care about evaluating the stack right now, only storing it for later
		#Important because state variables will change
		#Store global variables
		if new_container.name == "global decl":
			if next is Dictionary:
				var next_dict : Dictionary = next
				if next_dict.has("VAR?"):
					var variable_name : String = next["VAR="]
					push(SaveSystem.get_key(variable_name))
				elif next_dict.has("VAR="):
					var variable_name : String = next["VAR="]
					# don't reassign if already assigned
					if !SaveSystem.key_exists(variable_name):
						SaveSystem.set_key(variable_name, pop())
				elif string_evaluation_mode:
					if next_dict.has("->"):
						#get string value from redirect
						var redirect_name : String = next_dict["->"]
						var redirect_container : InkContainer = new_container.redirects[redirect_name]
						var first_line : InkLineInfo = redirect_container.dialogue_lines[0]
						string_eval_stream = string_eval_stream + first_line.text
			else:
				push(next)

		elif not string_evaluation_mode:
			if next is Dictionary:
				var next_dict : Dictionary = next
				if next_dict.has("^->") or next_dict.has("temp="):
					return
			print("Pushing to evaluation stack: ", next)
			push(next)
			'''
			Example:
				"ev",
				"str",
				"^If you're that worried...",
				"/str",
				"/ev",
			will result in:
				evaluation_stack_items = ["^If you're that worried..."]

			Example2:
				"ev",
				{
					"VAR?": "argue_SAM"
				},
				"/ev"
			will result in:
				evaluation_stack_items = [
				{
					"VAR?": "argue_SAM"
				}
				]
			'''
	elif not evaluation_mode: #not evaluation mode
		# CHOICES AND REDIRECTS
		if next is Dictionary:
			var next_dict : Dictionary = next
			if next_dict.has("*"):
				#Get choice text and any conditions that come with it (pushed on stack)
				var choice_text : String = string_eval_stream
				#print("Choice text: ", string_eval_stream)
				string_eval_stream = ""

				#Choice's redirect
				var redirect_location : String = next_dict["*"]

				#If 1 bit is set, store conditional statements on stack
				#these will be checked during runtime to decide whether to show the choice
				var eval_stack : Array = []
				var flag : int = next_dict["flg"]
				if int(flag)&1 == 1: #check if 1 bit is set 
					#Means it is conditional text
					eval_stack = evaluation_stack_items
					evaluation_stack_items = []
				
				InkChoiceInfo.new(
					new_container, 
					path, 
					choice_text,
					redirect_location,
					eval_stack,
				)
			elif next_dict.has("->"):
				var redirect : String = next_dict["->"]

				#conditional redirects
				var eval_stack : Array = []
				var condition : bool = true
				if next_dict.has("c"):
					condition = next_dict["c"]
					eval_stack = evaluation_stack_items
					evaluation_stack_items = []

				InkRedirect.new(
					new_container, 
					redirect,
					path,
					eval_stack,
				)

func break_up_dialogue(parent_container : InkContainer, path : String, dialogue:String) -> InkLineInfo:
	#name of speaker should be between brackets; if not, infer it from last speaker
	#print("Parsing string into line: ", dialogue)
	var char_name : String = ""
	var recording_name : bool = false
	var last_bracket_index : int = 0
	for n : int in range(dialogue.length()):
		var c : String = dialogue[n]
		if c == '[':
			recording_name = true
			continue
		elif c == ']':
			recording_name = false
			for i in range(n+1, dialogue.length()):
				if dialogue[i] != ' ': #set next index to first non-whitespace character
					last_bracket_index = i
					break
			#last_bracket_index = n+1
			break
		if recording_name:
			char_name = char_name + c
	
	var dialogue_text : String = dialogue.substr(last_bracket_index)

	#[Choice] means you are prefixing choice summary
	if char_name.length() == 0:
		char_name = last_speaker
	elif char_name == "ChoiceInfo": 
		#this will be appended to choices, not dialogue lines
		char_name = "ChoiceInfo"
		#set parent container to null so it doesn't get added to tree
		return InkLineInfo.new(null, path, char_name, dialogue_text)
	else:
		last_speaker = char_name
		
	return InkLineInfo.new(parent_container, path, char_name, dialogue_text)
