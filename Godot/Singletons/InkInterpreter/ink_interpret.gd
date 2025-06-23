extends Node

#all the variables
var rsc : Resource = load("res://Singletons/InkInterpreter/ink_interpret_resource.tres")

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
	for h in rsc.disappearing_choices:
		if match_hierarchies(h, h1):
			return true
	return false

func push_hierarchy(item : String): # can be string or index
	if item.is_valid_int():
	#if item is String:
		rsc.hierarchy.push_back(int(item)) #new index is zero
	else:
		rsc.hierarchy.push_back(item)
func pop_hierarchy():
	return rsc.hierarchy.pop_back()
	
func push_backup_hierarchy():
	if rsc.hierarchy.size() > 0:
		if current_container_name() is String:
			if current_container_name() != "global decl":
				rsc.backup_hierarchy.push_back(rsc.hierarchy.duplicate())
func push_redirect_hierarchy():
	if rsc.hierarchy.size() > 0:
		if current_container_name() is String:
			if current_container_name() == "global decl":
				return
		rsc.redirect_hierarchy.push_back(rsc.hierarchy.duplicate())

#INDEX STUFF
func current_index():
	return rsc.hierarchy.back()
func set_current_index(index):
	pop_hierarchy()
	rsc.hierarchy.push_back(index)
func increment_current_index():
	set_current_index(current_index()+1)
func decrement_current_index():
	set_current_index(current_index()-1)

#GET CURRENT CONTAINER INFO
func set_current_container(arr:Array, index:int):
	rsc.current_container_arr = arr
	rsc.current_container_i = index
func current_container_name():
	return rsc.hierarchy[rsc.current_container_i]
func current_container_size():
	return rsc.current_container_arr.size()
func current_container_inner_index():
	if current_container_name() is String:
		if current_container_name() == "root":
			return rsc.hierarchy[rsc.current_container_i+2]
			
	return rsc.hierarchy[rsc.current_container_i+1]

func get_scope(final_index : int):
	var current_scope = rsc.json_file #can be dictionary, array, or element
	if final_index == -1:
		final_index = rsc.hierarchy.size()-1
	print("getting scope: ", rsc.hierarchy.slice(0, final_index))
	for n in range(final_index): # exclude last element
		var path_item = rsc.hierarchy[n]
		current_scope = current_scope[path_item]
		if current_scope is Array:
			#SET REDIRECT TABLE IF ANY
			var final_element = current_scope.back()
			var second_to_last = current_scope[current_scope.size()-2]
			if final_element is Dictionary and !final_element.has("#f"): 
				# FOUND REDIRECT TABLE
				rsc.redirect_table = final_element
				rsc.redirect_table_address = current_scope.size()-1
				#print("Set redirect table: ", rsc.redirect_table_address)
				
				if rsc.redirect_table.has("c-0"): #real redirect table
					set_current_container(current_scope, n)
			elif second_to_last is String and second_to_last == "end": #second to last element is end
				set_current_container(current_scope, n)
			#END REDIRECT TABLE
	#default in case no valid container is found
	if rsc.current_container_i > rsc.hierarchy.size()-1:
		set_current_container(current_scope, rsc.hierarchy.size()-2)
	#print("Last scope: ", current_scope)
	return current_scope

func set_current_array():#redirect_item : bool):
	#print("Current scope: ", rsc.hierarchy, " | ", rsc.current_array)
	rsc.current_array = get_scope(-1)
	
	#Check if it's a redirect. If it is, we have to use the local redirect table
	if current_index() is String: #means it's a redirect
		var redirect_value : String = current_index()
		if rsc.redirect_table.has(current_index()): # otherwise, invalid address
			rsc.backup_hierarchy.pop_back()
			pop_hierarchy()
			push_hierarchy(str(rsc.redirect_table_address))
			push_hierarchy(redirect_value)
			push_hierarchy("0")
			rsc.current_array = rsc.redirect_table[redirect_value]
		else:
			rsc.hierarchy = rsc.backup_hierarchy.pop_back()
			increment_current_index()
		return

func into_array():
	#var new_arr = current_array[current_index()]
	push_hierarchy("0") #start on the first index of the new array
	set_current_array()

func exit_array():
	print("exit array current hierarchy: ", rsc.hierarchy, " | redirects: ", rsc.redirect_hierarchy)
	if rsc.redirect_hierarchy.size() > 0:
		print("redirect hierarchy has something: ", rsc.redirect_hierarchy)
		rsc.hierarchy = rsc.redirect_hierarchy.pop_back() #go to before redirect
	else:
		print("No redirect hierarchy: ", rsc.hierarchy)
		pop_hierarchy() #go to parent index
		if current_index() is String:
			print(current_index(), " is a String")
			pop_hierarchy()
	increment_current_index() #increment previous parent index
	set_current_array()

func jump_to_container(path:String): # for ->
	print("jumping to ", path, " from ", rsc.hierarchy)
	push_backup_hierarchy()
	var path_array = Array(path.split('.'))
	var directly_to_container : bool = false #if it's a redirect item, it has to be sent to the LOCAL redirect table (not necessarily the current one)
	if path[0] == '.': #relative path
		for n in range(1, path_array.size()): # exclude last element, skip first element (empty space)
			var item = path_array[n]
			if item == "^": #go up a parent in hierarchy (nearest ARRAY, not dict)
				pop_hierarchy()
				if (current_index() is String) and (current_index() == "b"): #nested inside a dictionary that you need to additionally pop
					pop_hierarchy()
			else:
				push_hierarchy(item)
	else: #absolute path
		if path_array.size() == 1 and !path_array.back().is_valid_int():
			path_array.push_back("0")
			rsc.redirect_hierarchy = []
			#rsc.redirect_hierarchy.pop_back() #we intend to stay in this container
		if path_array[0].is_valid_int(): #redirect value
			rsc.hierarchy = ["root"]
			for n in range(0,path_array.size()-1): #skip the last one
				var item = path_array.pop_front()
				push_hierarchy(item)
			push_hierarchy(path_array.back())
		else: #goes to a container
			rsc.hierarchy = ["root", 2] # set hierarchy to the 2nd element of root (where all the containers are stored)
			for item in path_array:
				push_hierarchy(item)
			rsc.redirect_hierarchy = []
			#rsc.redirect_hierarchy.pop_back()
		
	set_current_array() #sets current_array & current_index to the path specified in hierarchy

func push(value):
	rsc.evaluation_stack.push_back(value)
func pop():
	return rsc.evaluation_stack.pop_back()
func stack_top():
	return rsc.evaluation_stack.back()
func pushThread():
	rsc.all_evaluation_stacks.push_back(rsc.evaluation_stack.duplicate())
	rsc.evaluation_stack = rsc.all_evaluation_stacks.back()
func popThread():
	rsc.all_evaluation_stacks.pop_back()
	rsc.evaluation_stack = rsc.all_evaluation_stacks.back()
	
const ALL_OPERATORS : Array[String] = ["+", "-", "/", "*", "%", "==", ">", "<", ">=", "<=", "!=", "!", "&&", "||", "MIN", "MAX"]
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
	print("Redirect -> ", redirect_location)
	var condition_flag = pop() #condition_flag is pushed to the stack immediately preceding the check
	if next.has("c") and condition_flag != next["c"]: #checks condition if redirect calls for one
		print("Condition failed: ", redirect_location)
		print("Condition failed2: ", condition_flag, next["c"])
		return
	else:
		if next.has("c"):
			print("Condition succeeded: ", redirect_location)
		if redirect_location[0] != "$":
			push_redirect_hierarchy()
			jump_to_container(redirect_location)

func match_cmd(next):
	var command : int = 1
	match (next):
		"ev":
			rsc.evaluation_mode = true
		"/ev":
			rsc.evaluation_mode = false
		"str":
			rsc.string_evaluation_mode = true
		"/str":
			rsc.string_evaluation_mode = false
			push(rsc.string_eval_stream)
			rsc.string_eval_stream = ""
		"out":
			#pop & add to output
			var popped = pop()
			rsc.output_stream.push_back(popped)
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
			push(rsc.choiceCount)
		"turn":
			push(rsc.turn)
		"turns":
			var divert_target = pop()
			push(rsc.turn-rsc.containerDict[divert_target].last_turn_visited) #push # of turns since last visited
		"visit":
			#push # of visits to current container
			push(rsc.containerDict[current_container_name()].visits)
		"seq":
			pass
		"thread":
			print("Pushing thread")
			pushThread()
		"done":
			print("popping thread")
			popThread()
			#return
		"end":
			##print("Ended story!")
			return 405
		_:
			command = 0
	return command
			
func next_line():
	#set_current_array()
	if current_index() > rsc.current_array.size()-1: #skip the last element (the redirect table)
		print("Array index surpassed")
		return 404
	var next = rsc.current_array[current_index()]
	print("Next: ", rsc.hierarchy, next)
	
	var cmd_result : int = match_cmd(next)
	if cmd_result == 1: #command has been executed, break
		return
	elif cmd_result == 405: #command says to end dialogue
		return 405
	# NESTING
	if next is Array: #means there is a branch condition (either a choice or something condition-based)
		print("Going into array: ", rsc.hierarchy)
		into_array()
		return
	
	if next is String:
		if next[0] == '^': #is string
			next = next.substr(1)
			if next.replace(" ", "").length() == 0: #if it is just empty space
				return
			if rsc.string_evaluation_mode: #string eval mode takes precedence
				rsc.string_eval_stream = rsc.string_eval_stream + next
			else:
				var diag_dict = break_up_dialogue(next) #returns {"speaker":char_name, "text":dialogue_text}
				rsc.output_stream.push_back(diag_dict)
				return 200
				
	if rsc.evaluation_mode:
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
					rsc.tempVariableDict[next["temp="]] = pop()
				if rsc.string_evaluation_mode:
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
				rsc.player_choices.push_back({"text":choice_text, "jump":redirect_location})
				print("pushed player choices: ", rsc.player_choices)
			elif next.has("->"):
				redirect(next)
	return

func make_choice(redirect:String):
	print("jumping to ", redirect, " from ", rsc.hierarchy)
	jump_to_container(redirect)

func get_content():
	#print("calling next line", rsc.hierarchy)
	var og_container = current_container_name()
	var og_hierarchy_size = rsc.hierarchy.size()
	var result = next_line()
	#print("Current container index: ", rsc.current_container_i)
	if result != 404 and typeof(current_container_name()) == typeof(og_container) and (current_container_name() == og_container) and (rsc.hierarchy.size() == og_hierarchy_size):
		#ONLY increment if you are in the same location as before
		if rsc.resumed_hierarchy.size() > 0 && !(current_container_name() is String and current_container_name() == "global decl"):
			rsc.resumed_hierarchy = [] #don't increment if you just arrived here from unpausing dialogue
		else:
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
				#jump_to_container("0.0")
				#hierarchy = []
				initialize_hierarchy()
				return get_content()
		'''
		if the third to last hierarchy element is a number, that means we are in a nested array and 
		we need to get out before returning anything
		
		404: exiting ["root", 2, "one", 0, 23] (works correctly)
		404: exiting ["root", 2, "two", 0, 18, 2] (needs to be un-nested)

		'''
		print("Result: ", result, " Hierarchy: ", rsc.hierarchy)
		print("Current container inner index: ", current_container_inner_index(), " | size: ", current_container_size())
		print("Current index: ", current_index(), " | size: ", rsc.current_array.size(), " | redirect hierarchy: ", rsc.redirect_hierarchy.size())
		#if current_index() > current_array.size()-1 and redirect_hierarchy.size() == 0:#current_container_inner_index() > current_container_size()-1:
		if current_container_inner_index() > current_container_size()-1:
		#if current_index() > current_array.size()-1:
			#if we have reached the end of the array
			print("Passed all conditions")
			if rsc.player_choices.size() > 0:
				var return_choices = rsc.player_choices
				#output_stream = []
				rsc.player_choices = []
				print("Returning choices")
				return return_choices
		if result == 405:
			print("Ending: ", rsc.player_choices)
			return result
		else:
			var exit_array_return = exit_array()
			if exit_array_return != null:
				print("Exit array return not null")
				return exit_array_return
	elif result == 200: #returned a string
		if rsc.output_stream.size() > 0:
			var return_val = rsc.output_stream
			rsc.output_stream = []
			return return_val
	
	return get_content()

func reset_defaults(saved_ink_resource):#resume_from_hierarchy):
	#set all the variables equal to each other
	var property_list = saved_ink_resource.get_property_list()
	for n in range(9, property_list.size()):
		var key = property_list[n].name
		rsc[key] = saved_ink_resource[key]
		print("Setting key ", key, " to value ", rsc[key])
	
	rsc.player_choices = []
	rsc.output_stream = []
	print("resetting defaults: ", rsc.output_stream)
	rsc.resumed_hierarchy = rsc.hierarchy #will either be an empty array or the next hierarchy we need

func initialize_hierarchy():
	if rsc.resumed_hierarchy.size() > 0:
		#print("RESUMING FROM OLD INK: ", rsc.hierarchy)
		rsc.hierarchy = rsc.resumed_hierarchy
		set_current_array()
	else:
		jump_to_container("0.0")

func get_first_message(temp_json : JSON):
	var filepath = temp_json.resource_path
	var json_as_text : String = FileAccess.get_file_as_string(filepath)
	var json_as_dict : Dictionary = JSON.parse_string(json_as_text)
	if json_as_dict:
		return break_up_dialogue(json_as_dict["root"][0][0].substr(1))

func from_JSON(file : JSON, saved_ink_resource : Resource):#resume_from_hierarchy : Array = []):
	#reset variables
	reset_defaults(saved_ink_resource)#resume_from_hierarchy)
	if rsc.json_file == null or rsc.json_file.is_empty():
		var filepath = file.resource_path
		var json_as_text : String = FileAccess.get_file_as_string(filepath)
		var json_as_dict : Dictionary = JSON.parse_string(json_as_text)
		rsc.json_file = json_as_dict
	for container in rsc.json_file:
		rsc.containerDict[container] = {"visits":0, "last_turn_visited":0}
	if rsc.json_file["root"][2].has("global decl"):
		jump_to_container("global decl")
	else:
		initialize_hierarchy()
	
