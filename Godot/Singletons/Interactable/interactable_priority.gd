extends Node

#This is the interactable priorty. It determines which objects the player will interact with if there are
#2 or more possible interactables in range.

var interactable_priority : Array = []
var current_active_interactable : int = 0

func add_interactable(interactable : Interactable):
	interactable_priority.append(interactable)
	#current_active_interactable = interactable_priority[]
