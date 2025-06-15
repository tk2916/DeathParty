extends Node

var EXAMPLE_FILE : String = "res://example.ink2.json"
var json_file : Dictionary
#var current_container : String = "root" #initially, "done"."global decl" to initialize variables, then "root"
#var current_index : int = -1
var turn : int = 0 #advances each time Inky presents a choice to the player	
var redirect_table : Dictionary
var current_array : Array

var all_evaluation_stacks : Array = [[]] #when threading, tehre are multiple eval stacks
var evaluation_stack : Array = all_evaluation_stacks.back() #current eval stack
var output_stream : Array = [] #output to main text
var string_eval_stream : String = ""

var evaluation_mode : bool = false
var string_evaluation_mode : bool = false
var choiceCount : int = 0

var containerDict : Dictionary = {}
#var variableDict : Dictionary = {}

var tempVariableDict : Dictionary = {}

var condition_flag : bool = false #used for checks

var hierarchy:Array = []
var backup_hierarchy:Array = []
var redirect_hierarchy:Array = []
var player_choices:Array = []

var disappearing_choices:Array = []

func match_hierarchies(h1:Array, h2:Array):
	var matching = true
	if (h1.size() != h2.size()):
		matching = false
	else:
		for n in range(h1.size()):
			if h1[n] != h2[n]:
				matching = false
				break
	return matching
func already_chosen(h1:Array):
	for h in disappearing_choices:
		if match_hierarchies(h, h1):
			return true
	return false

func push_hierarchy(item:String): # can be string or index
	if item.is_valid_int():
	#if item is String:
		hierarchy.push_back(int(item)) #new index is zero
	else:
		hierarchy.push_back(item)
func pop_hierarchy():
	return hierarchy.pop_back()
	
func push_backup_hierarchy():
	if hierarchy.size() > 0:
		if current_container() != "global decl":
			backup_hierarchy.push_back(hierarchy.duplicate())
func push_redirect_hierarchy():
	if hierarchy.size() > 0:
		if current_container() != "global decl":
			redirect_hierarchy.push_back(hierarchy.duplicate())

#INDEX STUFF
func current_index():
	return hierarchy.back()
func set_current_index(index):
	pop_hierarchy()
	hierarchy.push_back(index)
func increment_current_index():
	###print("Incrementing")
	set_current_index(current_index()+1)
func decrement_current_index():
	set_current_index(current_index()-1)
#GET CURRENT CONTAINER
func current_container():
	for n in range(hierarchy.size()-1, 0, -1): #check backwards
		var item = hierarchy[n]
		if item is String:
			return item #returns first string (container name)

func set_current_array():
	if current_index() is String: #then that means it's a redirect table operation
		##print("JUMPING to ", current_index())
		
		if redirect_table.has(current_index()): # otherwise, invalid address
			#print("founding redirect")
			backup_hierarchy.pop_back()
			current_array = redirect_table[current_index()]
			push_hierarchy("0") #start at 0th index
		else:
			#print("Invalid address: ", hierarchy)
			hierarchy = backup_hierarchy.pop_back()
			increment_current_index()
			#pop_hierarchy()
			#increment_current_index()
			##print("New hierarchy: ", hierarchy)
			#set_current_array()
		return
	var current_scope = json_file
	for n in range(hierarchy.size()-1): # exclude last element
		var path_item = hierarchy[n]
		#if current_scope.has(path_item):
		current_scope = current_scope[path_item]
		
	current_array = current_scope
	if current_array.back() is Dictionary:
		redirect_table = current_array.back()
	##print("Setting array for ", hierarchy)
	
func into_array():
	#print("into array : ", hierarchy)
	#var new_arr = current_array[current_index()]
	push_hierarchy("0") #start on the first index of the new array
	###print("into array after: ", current_array)
	set_current_array()

func exit_array():
	#print("exit array current hierarchy: ", hierarchy, redirect_hierarchy)
	if redirect_hierarchy.size() > 0:
		hierarchy = redirect_hierarchy.pop_back() #go to before redirect
		#print("Backup hierarchy: ", hierarchy)
	else:
		pop_hierarchy() #go to parent
		#if (current_index() is String):
		#	exit_array()
	increment_current_index() #increment previous parent index
	set_current_array()

func jump_to_container(path:String): # for ->
	#clear variables
	#player_choices = []
	print("Pushing backup hierarchy: ", hierarchy, " going to ", path)
	push_backup_hierarchy()
	#print("Backup hierarchies: ", backup_hierarchy)
	var path_array = Array(path.split('.'))
	if path[0] == '.': #relative path
		for n in range(1, path_array.size()): # exclude last element, skip first element (empty space)
			var item = path_array[n]
			if item == "^": #go up a parent in hierarchy
				pop_hierarchy()
				##print("Going up parent directory: ", hierarchy)
			else:
				push_hierarchy(item)
	else: #absolute path
		if path_array.size() == 1 and !path_array.back().is_valid_int():
			#if it is just referring to a container alone, e.g. "two",
			#specify that you want the first index of the container (the dialogue)
			path_array.push_back("0")
		var initial_index = 2
		if path_array[0].is_valid_int():
			initial_index = int(path_array.pop_front())
		hierarchy = ["root", initial_index] # set hierarchy to the 2nd element of root (where all the containers are stored)
		
		for item in path_array:
			push_hierarchy(item)
		
	set_current_array() #sets current_array & current_index to the path specified in hierarchy

func from_JSON(file : JSON):
	#var json_as_text : String = file.get_parsed_text()#JSON.stringify(file)
	var filepath = file.resource_path
	var json_as_text : String = FileAccess.get_file_as_string(filepath)
	var json_as_dict : Dictionary = JSON.parse_string(json_as_text)
	#from_JSON(json_as_text)
	#var json_as_dict : Dictionary = JSON.parse_string(json_as_text)
	if json_as_dict:
		json_file = json_as_dict
		jump_to_container("global decl")
		for container in json_file:
			containerDict[container] = {"visits":0, "last_turn_visited":0}

func push(value):
	evaluation_stack.push_back(value)
func pop():
	return evaluation_stack.pop_back()
func stack_top():
	return evaluation_stack.back()
func pushThread():
	all_evaluation_stacks.push_back(evaluation_stack.duplicate())
	evaluation_stack = all_evaluation_stacks.back()
func popThread():
	all_evaluation_stacks.pop_back()
	evaluation_stack = all_evaluation_stacks.back()
	
const ALL_OPERATORS = ["+", "-", "/", "*", "%", "==", ">", "<", ">=", "<=", "!=", "!", "&&", "||", "MIN", "MAX"]
func operate(op, arg1, arg2):
	if arg2 != null:
		if typeof(arg1) != typeof(arg2):
			#puts them both in true or false terms
			arg1 = !!arg1
			arg2 = !!arg2
	##print("OPERATING: ", arg1, op, arg2)
	var result
	match (op):
		"+":
			result = arg1+arg2
		"-":
			result = arg1-arg2
		"/":
			result = arg1/arg2
		"*":
			result = arg1*arg2
		"%":
			result = arg1%arg2
		"==":
			result = arg1==arg2
		">":
			result = arg1>arg2
		"<":
			result = arg1<arg2
		">=":
			result = arg1>=arg2
		"<=":
			result = arg1<=arg2
		"!=":
			result = arg1!=arg2
		"!":
			result = !arg1
		"&&":
			result = arg1&&arg2
		"||":
			result = arg1||arg2
		"MIN":
			result = min(arg1,arg2)
		"MAX":
			result = max(arg1,arg2)
		_:
			result = "No operation: " + op
	if result is bool:
		condition_flag = result
		##print("result: ", condition_flag)
	push(result)
	return result

func logical_operation(current_operator):
	var arg1 = pop()
	var arg2 = null
	if current_operator != "!": # ! is a single argument function
		arg2 = pop()
	return operate(current_operator, arg2, arg1)

var last_speaker : String = ""
func break_up_dialogue(dialogue:String):
	#name of speaker should be between brackets; if not, infer it from last speaker
	var char_name : String = ""
	var recording_name : bool = false
	var last_bracket_index = 0
	for n in range(dialogue.length()):
		var c = dialogue[n]
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
			
	if char_name.length() == 0:
		char_name = last_speaker
	else:
		last_speaker = char_name
		
	var dialogue_text = dialogue.substr(last_bracket_index)
	return {"speaker":char_name, "text":dialogue_text}

func next_line():
	if current_index() > current_array.size()-1: #skip the last element (the redirect table)
		return 404
	var next = current_array[current_index()]
	##print("Next: ", next)
	var command = true
	match (next):
		"ev":
			evaluation_mode = true
		"/ev":
			evaluation_mode = false
		"str":
			string_evaluation_mode = true
		"/str":
			string_evaluation_mode = false
			push(string_eval_stream)
			string_eval_stream = ""
		"out":
			#pop & add to output
			var popped = pop()
			output_stream.push_back(popped)
		"pop":
			#pop w/o adding to output
			pop()
		"du":
			#duplicate item on eval stack
			push(stack_top())
		"nop":
			#does nothing
			pass
		"choiceCnt":
			push(choiceCount)
		"turn":
			push(turn)
		"turns":
			var divert_target = pop()
			push(turn-containerDict[divert_target].last_turn_visited) #push # of turns since last visited
		"visit":
			#push # of visits to current container
			push(containerDict[current_container].visits)
		"seq":
			pass
		"thread":
			print("Pushing thread")
			pushThread()
		"done":
			print("popping thread")
			popThread()
		"end":
			##print("Ended story!")
			return 405
		_:
			command = false
	if command:
		return
	
	# NESTING
	if next is Array: #means there is a branch condition (either a choice or something condition-based)
		into_array()
		return
	
	if next is String:
		if next[0] == '^': #is string
			next = next.substr(1)
			if next.replace(" ", "").length() == 0: #if it is just empty space
				return
			if string_evaluation_mode: #string eval mode takes precedence
				#print("adding to str eval mode: ", next)
				string_eval_stream = string_eval_stream + next
			else:
				var diag_dict = break_up_dialogue(next) #returns {"speaker":char_name, "text":dialogue_text}
				output_stream.push_back(diag_dict)
				print("Pushing back: ", diag_dict)
				return 200
				
	if evaluation_mode:
		##print("in eval mode")
		if ALL_OPERATORS.has(next):
			logical_operation(next)
		else:
			if next is Dictionary:
				if next.has("VAR?"):
					###print("Next: ", next)
					#push(variableDict[next["VAR?"]])
					push(SaveSystem.get_key(next["VAR?"]))
				elif next.has("VAR="):
					if current_container() == "global decl": #if we are doing initial assignments, don't overwrite prior data
						if SaveSystem.key_exists(next["VAR="]):
							#### IMPORTANT!!!!! don't reassign if already assigned
							return
					#variableDict[next["VAR="]] = pop()
					SaveSystem.set_key(next["VAR="], pop())
					##print("VAR ", next["VAR="], " now equals ", variableDict[next["VAR="]])
				elif next.has("^->"):
					push(next["^->"])
				elif next.has("temp="):
					tempVariableDict[next["temp="]] = pop()
				if string_evaluation_mode:
					##print("")
					if next.has("->"):
						if next["->"][0] != "$":
							#print("Pushing backup hierarchy2: ", hierarchy)
							push_redirect_hierarchy()
							jump_to_container(next["->"])
			else:
				push(next)
	else:
		# CHOICES AND REDIRECTS
		if next is Dictionary:
			if next.has("*"):
				if next["flg"] == 20:
					#print("Has flag 20")
					if already_chosen(hierarchy): #make option disappear if player has already selected it
						##print("Not chosen yet")
						return
					else:
						disappearing_choices.push_back(hierarchy)
						##print("pushed:", disappearing_choices)
				elif int(next["flg"])&1 == 1: #check if 1 bit is set 
					#Means it is conditional text
					#pop a value off the eval stack to see if you should show it
					print("1 bit set: ", next["flg"], next["*"])
					var true_false : bool = pop()
					if true_false == false:
						return
					
				#then it is a choice. Pop the choice's text from off the stack
				
				var choice_text = pop()
				#print("popping choice text: ", choice_text)
				if choice_text is bool:
					#then there was a condition for this option to show up
					if choice_text:
						choice_text = pop() #the next one down will be the actual text
					else:
						return
				#print("popping choice text2: ", choice_text)
				var redirect_location = next["*"]
				player_choices.push_back({"text":choice_text, "jump":redirect_location})
			elif next.has("->"):
				#print("Has redirect: ", next)
				if next.has("c") and condition_flag != next["c"]: #checks condition if redirect calls for one
					#NEED TO BE ABLE TO DO THIS PER TEXT LINE
					#print("Failed condition")
					#condition_flag is set by evaluation mode immediately preceding the check
					return
				else:
					if next.has("c"):
						print("Condition succeeded ", condition_flag, " ", next["c"])
					#this is a redirect (does not wait for player input)
					##print("Pushing backup hierarchy1: ", hierarchy)
					#push_backup_hierarchy()
					var redirect_location = next["->"]
					jump_to_container(redirect_location)
	return

func make_choice(redirect:String):
	print("jumping to ", redirect, " from ", hierarchy, " and ", redirect_table)
	jump_to_container(redirect)

func get_content():
	print("calling next line", hierarchy)
	var og_container = current_container()
	var og_hierarchy_size = hierarchy.size()
	var result = next_line()
	if (current_container() == og_container) and (hierarchy.size() == og_hierarchy_size):
		#ONLY increment if you are in the same location as before
		increment_current_index() #next line
	
	if result == 404 || result == 405: #reached end of section, return data
		if current_container() == "global decl": #it just finished assigning variables, time to send it to main dialogue
			##print("Jumping back")
			jump_to_container("0.0")
			print("404!!")
			return get_content()
		'''
		if the third to last hierarchy element is a number, that means we are in a nested array and 
		we need to get out before returning anything
		
		404: exiting ["root", 2, "one", 0, 23] (works correctly)
		404: exiting ["root", 2, "two", 0, 18, 2] (needs to be un-nested)

		'''
		if hierarchy[hierarchy.size()-3] is String or result == 405: #"end" returns 405 #
			#print("Ending: ", player_choices)
			#var return_val = output_stream
			if player_choices.size() > 0:
				var return_choices = player_choices
				#output_stream = []
				player_choices = []
				return return_choices#{"dialogue" : return_val, "choices" : return_choices}
		else:
			if hierarchy[hierarchy.size()-2] is String:
				return 405
			exit_array()
	if result == 200: #returned a string
		print("Returning string")
		if output_stream.size() > 0:
			var return_val = output_stream
			output_stream = []
			return return_val
	
	return get_content()
	
