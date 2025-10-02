extends Node
# This handles the priority of interactables. It determines which object the
# player will interact with if there are 2 or more possible interactables in range.


var interactable_priority_list : Array = []
var active_interactable : Interactable = null


func add_interactable(interactable : Interactable) -> void:
	print("adding ", interactable.name, " to interactable priority list")

	# add the new interactable,
	interactable_priority_list.append(interactable)

	# and set it as the active interactable
	active_interactable = interactable_priority_list[-1]


func remove_interactable(interactable : Interactable) -> void:
	print("removing ", interactable.name, " from interactable priority list")
	# if this interactable is the active one, remove it and make
	# the next one in the list active
	if interactable == active_interactable:
		interactable_priority_list.pop_back()
		if not interactable_priority_list.is_empty():
			active_interactable = interactable_priority_list[-1]

	# otherwise, just remove it from the list
	else:
		var i: int = interactable_priority_list.find(interactable)
		interactable_priority_list.pop_at(i)
