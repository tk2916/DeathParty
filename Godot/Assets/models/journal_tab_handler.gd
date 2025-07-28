extends Node
class_name JournalTabHandler

var left_tabs : Array[Node]
var right_tabs : Array[Node]

var amount_of_tabs : int

'''
Tab index = tab # out of list of tabs only
Page number = page # out of all pages of journal
EXAMPLE:
	[1] = true #shows up on the left side
	[2] = false #shows up on the right side
'''
var tab_index_to_side : Array[bool] = []

var SIDES : Dictionary[String, bool] = {
	"LEFT":true, 
	"RIGHT":false
}

#all tabs are on the right at the beginning
func _init(_left_tabs : Array[Node], _right_tabs : Array[Node]) -> void:
	print("Tab handler")
	left_tabs = _left_tabs
	right_tabs = _right_tabs
	amount_of_tabs = left_tabs.size()
	for n in range(amount_of_tabs):
		tab_index_to_side.push_back(SIDES.RIGHT)
	flip_page(0)

func toggle_tab_visibility(to_side : bool, tab_index : int):
	right_tabs[tab_index].toggle_visible(!to_side)
	left_tabs[tab_index].toggle_visible(to_side)

func compare_tab_page(tab_index : int, page_number : int, tab_page_number : int):
	if tab_page_number > page_number:
		tab_index_to_side[tab_index] = SIDES.RIGHT
		toggle_tab_visibility(SIDES.RIGHT, tab_index)
	elif tab_page_number <= page_number:
		tab_index_to_side[tab_index] = SIDES.LEFT
		toggle_tab_visibility(SIDES.LEFT, tab_index)

func flip_page(page_number : int): #sets tabs to appropriate locations
	for tab_index in range(amount_of_tabs):
		#tab page number is the same on the right & left sides
		var tab_page_number = left_tabs[tab_index].flip_to_page
		compare_tab_page(tab_index, page_number, tab_page_number)
	
func get_tab(tab_index : int):
	var return_tab : Node
	#will either return the tab from the right or left side
	if tab_index_to_side[tab_index] == true:
		return_tab = left_tabs[tab_index]
	else:
		return_tab = right_tabs[tab_index]
	return return_tab

func get_tab_from_page_number(page_number : int):
	print("Getting tab for page # : ", page_number)
	var tab_index = 0
	for tab in left_tabs:
		if page_number == tab.flip_to_page: #find the tab with that page num
			break
		tab_index += 1
		
	#return the left or right tab (depending on which is active)
	return get_tab(tab_index)
