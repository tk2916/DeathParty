extends Node
# This handles the priority of interactables. It determines which object the
# player will interact with if there are 2 or more possible interactables in range.


var interactable_priority_list : Array = []
var active_interactable : Interactable = null


# NOTE: these enable and disable funcs took InteractionDetectors as parameters
#		, i changed them to take Interactables so some of these methods like
#		disable() getting called are probably unsafe for now
#			- jack
func add_interactable(interactable : Interactable) -> void:
	print("adding ", interactable.name, " to interactable priority list")

	# if there's an active interactable, disable it

	# NOTE: do we need to disable anything ? if we're setting the new
	#		interactable to active in the same frame, and there's only one
	#		active at a time, won't that have the desired behaviour anyway ?
	#			- jack
	if active_interactable != null:
		active_interactable.disable()

	# then add the new interactable,
	interactable_priority_list.append(interactable)
	
	# set it as the active interactable,
	active_interactable = interactable_priority_list[-1]

	# and enable it
	active_interactable.enable()


func remove_interactable(interactable : Interactable) -> void:
	print("removing ", interactable.name, " from interactable priority list")
	
	# if this interactable is the active one, remove it and make
	# the next one in the list active
	if interactable == active_interactable:
		# NOTE: again, i wonder if disabling is necessary here
		#			- jack
		active_interactable.disable()
		interactable_priority_list.pop_back()
		if not interactable_priority_list.is_empty():
			active_interactable = interactable_priority_list[-1]
			active_interactable.enable()

	# otherwise, just remove it from the list
	else:
		var i: int = interactable_priority_list.find(interactable)
		interactable.disable()
		interactable_priority_list.pop_at(i)
