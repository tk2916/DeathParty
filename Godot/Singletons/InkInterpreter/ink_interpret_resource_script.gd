extends Resource

#overall file
@export var json_file : Dictionary

#hierarchies
@export var hierarchy:Array = []
@export var resumed_hierarchy:Array = []
@export var backup_hierarchy:Array = []
@export var redirect_hierarchy:Array = []
@export var player_choices:Array = []

#important arrays & dictionaries
@export var redirect_table : Dictionary
@export var redirect_table_address : int
@export var current_array : Array

#keeps track of the current overall container
@export var current_container_i : int
@export var current_container_arr : Array

#Evaluation mode
@export var evaluation_mode : bool = false
@export var string_evaluation_mode : bool = false
@export var all_evaluation_stacks : Array = [[]] #when threading, tehre are multiple eval stacks
@export var evaluation_stack : Array = all_evaluation_stacks.back() #current eval stack
@export var output_stream : Array = [] #output dialogue & choices to main text
@export var string_eval_stream : String = ""

#NOT IMPLEMENTED YET -------------------------------
@export var turn : int = 0 #advances each time Inky presents a choice to the player
@export var choiceCount : int = 0
#temp @export variables (not implemented)
@export var variableDict : Dictionary = {}
@export var tempVariableDict : Dictionary = {}
#for one-time choices (not implemented yet)
@export var containerDict : Dictionary = {}
@export var disappearing_choices:Array = []

#func deep_copy():
	#@export var property_list = get_property_list()
	#@export var new_rsc = duplicate()
	#
	#for n in range(9, property_list.size()):
		#@export var key = property_list[n].name
		#if self[key] is Array:
			#new_rsc[key] = []
			#for item in self[key]:
				#new_rsc[key].push_back(item)
	#new_rsc.hierarchy
