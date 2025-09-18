extends Node

#This is the interactable priorty. It determines which objects the player will interact with if there are
#2 or more possible interactables in range.

var interactable_priority : Array = []
var active_interactable : InteractionDetector = null

func add_interactable(interactable : InteractionDetector):
	print("Interactable: ", interactable)
	#Disable Active
	if active_interactable != null:
		active_interactable.disable()
	
	#Add the new interactable
	interactable_priority.append(interactable)
	
	#Set active to new one
	active_interactable = interactable_priority[-1]
	active_interactable.enable()

func remove_interactable(interactable : InteractionDetector):
	#If the chosen interactable is the active one : Remove it and replace it with the next active
	if interactable == active_interactable:
		active_interactable.disable()
		interactable_priority.pop_back()
		if not interactable_priority.is_empty():
			active_interactable = interactable_priority[-1]
		active_interactable.enable()
	else:
		#Find the interactable and remove it
		for i in range(interactable_priority.size()):
			if interactable == interactable_priority[i]:
				interactable_priority.pop_at(i)
