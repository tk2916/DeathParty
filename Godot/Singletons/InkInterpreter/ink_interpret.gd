extends Node

var json_file : Dictionary

var turn : int = 0 #advances each time Inky presents a choice to the player	
var redirect_table : Dictionary
var redirect_table_address : int
var current_array : Array

var current_container_i : int
var current_container_arr : Array

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

var choices_are_in_individual_arrays : bool = false

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

func push_hierarchy(item : String): # can be string or index
	if item.is_valid_int():
	#if item is String:
		hierarchy.push_back(int(item)) #new index is zero
	else:
		hierarchy.push_back(item)
func pop_hierarchy():
	return hierarchy.pop_back()
	
func push_backup_hierarchy():
	if hierarchy.size() > 0:
		if current_container_name() is String:
			if current_container_name() != "global decl":
				backup_hierarchy.push_back(hierarchy.duplicate())
func push_redirect_hierarchy():
	print("in push redirect function")
	if hierarchy.size() > 0:
		if current_container_name() is String:
			if current_container_name() == "global decl":
				return
		redirect_hierarchy.push_back(hierarchy.duplicate())

#INDEX STUFF
func current_index():
	return hierarchy.back()
func set_current_index(index):
	pop_hierarchy()
	hierarchy.push_back(index)
func increment_current_index():
	#print("Incrementing ", current_index())
	set_current_index(current_index()+1)
func decrement_current_index():
	set_current_index(current_index()-1)

#GET CURRENT CONTAINER INFO
func set_current_container(arr:Array, index:int):
	current_container_arr = arr
	current_container_i = index
	print("New container name: ", current_container_name())
func current_container_name():
	return hierarchy[current_container_i]
func current_container_size():
	return current_container_arr.size()
func current_container_inner_index():
	print("Current container name: ", current_container_name())
	if current_container_name() is String:
		if current_container_name() == "root":
			return hierarchy[current_container_i+2]
			
	return hierarchy[current_container_i+1]

func get_scope(final_index : int):
	var current_scope = json_file #can be dictionary, array, or element
	if final_index == -1:
		final_index = hierarchy.size()-1
	print("getting scope: ", hierarchy.slice(0, final_index))
	for n in range(final_index): # exclude last element
		var path_item = hierarchy[n]
		current_scope = current_scope[path_item]
		#print("scope n: ", n, " | ", current_scope)
		if current_scope is Array:
			#SET REDIRECT TABLE IF ANY
			var final_element = current_scope.back()
			var second_to_last = current_scope[current_scope.size()-2]
			if final_element is Dictionary and !final_element.has("#f"): 
				# FOUND REDIRECT TABLE
				redirect_table = final_element
				redirect_table_address = current_scope.size()-1
				print("Set redirect table: ", redirect_table_address)
				
				if redirect_table.has("c-0"): #real redirect table
					#print("Redirect table has c-0: ", redirect_table)
					set_current_container(current_scope, n)
			elif second_to_last is String and second_to_last == "end": #second to last element is end
				print("Hierarchy for end: ", hierarchy)
				print("Scope for end: ", current_scope)
				set_current_container(current_scope, n)
			#END REDIRECT TABLE
	#default in case no valid container is found
	if current_container_i > hierarchy.size()-1:
		print("DEFAULT USED: ", hierarchy, " | ", hierarchy.size()-2, " | ", current_container_i)
		set_current_container(current_scope, hierarchy.size()-2)
	#print("Last scope: ", current_scope)
	return current_scope

func set_current_array():#redirect_item : bool):
	#print("Current scope: ", hierarchy, " | ", current_array)
	current_array = get_scope(-1)
	print("Current container: ", current_container_name())
	
	#Check if it's a redirect. If it is, we have to use the local redirect table
	if current_index() is String: #means it's a redirect
		var redirect_value : String = current_index()
		print("Redirect item ", redirect_value, " in table ", hierarchy)
		if redirect_table.has(current_index()): # otherwise, invalid address
			backup_hierarchy.pop_back()
			pop_hierarchy()
			push_hierarchy(str(redirect_table_address))
			push_hierarchy(redirect_value)
			push_hierarchy("0")
			current_array = redirect_table[redirect_value]
		else:
			hierarchy = backup_hierarchy.pop_back()
			increment_current_index()
		return

func into_array():
	print("into array : ", hierarchy)
	#var new_arr = current_array[current_index()]
	push_hierarchy("0") #start on the first index of the new array
	####print("into array after: ", current_array)
	set_current_array()

func exit_array():
	print("exit array current hierarchy: ", hierarchy, redirect_hierarchy)
	if redirect_hierarchy.size() > 0:
		print("redirect hierarchy has something: ", redirect_hierarchy)
		hierarchy = redirect_hierarchy.pop_back() #go to before redirect
	else:
		print("No redirect hierarchy: ", hierarchy)
		#while current_index() is String:
		#print("Exit array hierarchy before pop: ", hierarchy)
		pop_hierarchy() #go to parent index
		if current_index() is String:
			print(current_index(), " is a String")
			pop_hierarchy()
		#	pop_hierarchy()
	increment_current_index() #increment previous parent index
	#print("After exit hierarchy: ", hierarchy)
	set_current_array()

func jump_to_container(path:String): # for ->
	print("jumping to ", path)
	push_backup_hierarchy()
	var path_array = Array(path.split('.'))
	var directly_to_container : bool = false #if it's a redirect item, it has to be sent to the LOCAL redirect table (not necessarily the current one)
	if path[0] == '.': #dddive path
		for n in range(1, path_array.size()): # exclude last element, skip first element (empty space)
			var item = path_array[n]
			if item == "^": #go up a parent in hierarchy
				pop_hierarchy()
			else:
				push_hierarchy(item)
	else: #absolute path
		if path_array.size() == 1 and !path_array.back().is_valid_int():
			path_array.push_back("0")
			redirect_hierarchy.pop_back() #we intend to stay in this container
		if path_array[0].is_valid_int(): #redirect value
			hierarchy = ["root"]
			for n in range(0,path_array.size()-1): #skip the last one
				var item = path_array.pop_front()
				push_hierarchy(item)
			push_hierarchy(path_array.back())
		else:
			##print("Down here: ", path_array)
			hierarchy = ["root", 2] # set hierarchy to the 2nd element of root (where all the containers are stored)
			for item in path_array:
				push_hierarchy(item)
		print("Hierarchy now: ", hierarchy)
		
	set_current_array() #sets current_array & current_index to the path specified in hierarchy

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
	
const ALL_OPERATORS : Array[String] = ["+", "-", "/", "*", "%", "==", ">", "<", ">=", "<=", "!=", "!", "&&", "||", "MIN", "MAX"]
func operate(op, arg1, arg2):
	if arg2 != null:
		if typeof(arg1) != typeof(arg2):
			#puts them both in true or false terms
			arg1 = !!arg1
			arg2 = !!arg2
	###print("OPERATING: ", arg1, op, arg2)
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
		###print("result: ", condition_flag)
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

func redirect(next):
	var redirect_location = next["->"]
	if next.has("c") and condition_flag != next["c"]: #checks condition if redirect calls for one
		#condition_flag is set by evaluation mode immediately preceding the check
		print("Condition failed: ", SaveSystem.get_key("catchup_Nora"))
		return
	else:
		if redirect_location[0] != "$":
			print("Pushing redirect hierarchy and jumping to ", redirect_location)
			push_redirect_hierarchy()
			print("Redirect hierarchy now: ", redirect_hierarchy)
			jump_to_container(redirect_location)

func match_cmd(next):
	var command : int = 1
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
			push(containerDict[current_container_name()].visits)
		"seq":
			pass
		"thread":
			#print("Pushing thread")
			pushThread()
		"done":
			#print("popping thread")
			popThread()
			#return
		"end":
			###print("Ended story!")
			return 405
		_:
			command = 0
	return command
			
func next_line():
	#set_current_array()
	if current_index() > current_array.size()-1: #skip the last element (the redirect table)
		print("Array index surpassed")
		return 404
	var next = current_array[current_index()]
	print("Next: ", hierarchy, " ", next)
	
	var cmd_result : int = match_cmd(next)
	if cmd_result == 1: #command has been executed, break
		return
	elif cmd_result == 405: #command says to end dialogue
		return 405
	# NESTING
	if next is Array: #means there is a branch condition (either a choice or something condition-based)
		print("Going into array: ", hierarchy)
		into_array()
		return
	
	if next is String:
		if next[0] == '^': #is string
			next = next.substr(1)
			if next.replace(" ", "").length() == 0: #if it is just empty space
				return
			if string_evaluation_mode: #string eval mode takes precedence
				string_eval_stream = string_eval_stream + next
			else:
				var diag_dict = break_up_dialogue(next) #returns {"speaker":char_name, "text":dialogue_text}
				output_stream.push_back(diag_dict)
				return 200
				
	if evaluation_mode:
		if ALL_OPERATORS.has(next):
			logical_operation(next)
		else:
			if next is Dictionary:
				if next.has("VAR?"):
					push(SaveSystem.get_key(next["VAR?"]))
				elif next.has("VAR="):
					print("Requesting variable ", next["VAR="])
					if (current_container_name() is String) and current_container_name() == "global decl": #if we are doing initial assignments, don't overwrite prior data
						print("doing global declaration for ", next["VAR="])
						if SaveSystem.key_exists(next["VAR="]):
							#### IMPORTANT!!!!! don't reassign if already assigned
							return
					SaveSystem.set_key(next["VAR="], pop())
				elif next.has("^->"):
					push(next["^->"])
				elif next.has("temp="):
					tempVariableDict[next["temp="]] = pop()
				if string_evaluation_mode:
					if next.has("->"):
						print("Has -> ", next["->"])
						redirect(next)
			else:
				push(next)
	else: #not evaluation mode
		# CHOICES AND REDIRECTS
		if next is Dictionary:
			if next.has("*"):
				if next["flg"] == 20:
					pass
				elif int(next["flg"])&1 == 1: #check if 1 bit is set 
					#Means it is conditional text
					#pop a value off the eval stack to see if you should show it
					var true_false : bool = pop()
					if true_false == false:
						return
					
				#then it is a choice. Pop the choice's text from off the stack
				var choice_text = pop()
				if choice_text is bool:
					#then there was a condition for this option to show up
					if choice_text:
						choice_text = pop() #the next one down will be the actual text
					else:
						return
				var redirect_location = next["*"]
				player_choices.push_back({"text":choice_text, "jump":redirect_location})
				print("pushed player choices: ", player_choices)
			elif next.has("->"):
				redirect(next)
	return

func make_choice(redirect:String):
	##print("jumping to ", redirect, " from ", hierarchy, " and ", redirect_table)
	jump_to_container(redirect)

func get_content():
	#print("calling next line", hierarchy)
	var og_container = current_container_name()
	var og_hierarchy_size = hierarchy.size()
	var result = next_line()
	print("Current container index: ", current_container_i)
	if result != 404 and typeof(current_container_name()) == typeof(og_container) and (current_container_name() == og_container) and (hierarchy.size() == og_hierarchy_size):
		#ONLY increment if you are in the same location as before
		increment_current_index() #next line
	#elif result == 404:
		#decrement_current_index()
	'''
	404: Array index surpassed
	405: Reached "end" command
	'''
	if result == 404 || result == 405: #reached end of section, return data
		print("404 warnihg!")
		if current_container_name() is String:
			if current_container_name() == "global decl": #it just finished assigning variables, time to send it to main dialogue
				###print("Jumping back")
				jump_to_container("0.0")
				#print("404!!")
				return get_content()
		'''
		if the third to last hierarchy element is a number, that means we are in a nested array and 
		we need to get out before returning anything
		
		404: exiting ["root", 2, "one", 0, 23] (works correctly)
		404: exiting ["root", 2, "two", 0, 18, 2] (needs to be un-nested)

		'''
		print("Result: ", result, " Hierarchy: ", hierarchy)
		print("Current container inner index: ", current_container_inner_index(), " | size: ", current_container_size())
		print("Current index: ", current_index(), " | size: ", current_array.size(), " | redirect hierarchy: ", redirect_hierarchy.size())
		#if current_index() > current_array.size()-1 and redirect_hierarchy.size() == 0:#current_container_inner_index() > current_container_size()-1:
		if current_container_inner_index() > current_container_size()-1:
		#if current_index() > current_array.size()-1:
			#if we have reached the end of the array
			print("Passed all conditions")
			if player_choices.size() > 0:
				var return_choices = player_choices
				#output_stream = []
				player_choices = []
				print("Returning choices")
				return return_choices
		if result == 405:
			print("Ending: ", player_choices)
			return result
		else:
			var exit_array_return = exit_array()
			if exit_array_return != null:
				print("Exit array return not null")
				return exit_array_return
	elif result == 200: #returned a string
		if output_stream.size() > 0:
			var return_val = output_stream
			output_stream = []
			return return_val
	
	return get_content()

func reset_defaults():
	hierarchy = []
	backup_hierarchy = []
	redirect_hierarchy = []
	player_choices = []
	evaluation_stack = []
	all_evaluation_stacks = []

func from_JSON(file : JSON):
	#reset variables
	reset_defaults()
	var filepath = file.resource_path
	var json_as_text : String = FileAccess.get_file_as_string(filepath)
	var json_as_dict : Dictionary = JSON.parse_string(json_as_text)
	if json_as_dict:
		json_file = json_as_dict
		for container in json_file:
			containerDict[container] = {"visits":0, "last_turn_visited":0}
		if json_as_dict["root"][2].has("global decl"):
			print("jumping for global decl")
			jump_to_container("global decl")
		else:
			jump_to_container("0.0")
	
