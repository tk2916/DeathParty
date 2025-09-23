extends Node
class_name JournalTabHandler

var tabs : Array[JournalTab]

var amount_of_tabs : int

var bookflip : BookFlip

#all tabs are on the right at the beginning
func _init(_bookflip : BookFlip, _tabs : Array[JournalTab]) -> void:
	tabs = _tabs
	bookflip = _bookflip
	amount_of_tabs = tabs.size()
	flip_page(0)

	for tab in tabs:
		tab.tab_pressed.connect(on_tab_pressed.bind(tab))

func on_tab_pressed(tab:JournalTab) -> void:
	bookflip.flip_to_page(tab.flip_to_page)

func flip_page(page_number : int) -> void: #toggles tab textures
	for tab_index in range(amount_of_tabs):
		#tab page number is the same on the right & left sides
		var tab : JournalTab = tabs[tab_index]
		var tab_page_number : int = tab.flip_to_page
		if tab_page_number == page_number:
			tab.tab_opened()
		else:
			tab.tab_closed()
	
func get_tab(tab_index : int) -> JournalTab:
	return tabs[tab_index]

func get_tab_from_page_number(page_number : int) -> JournalTab:
	print("Getting tab for page num : ", page_number)
	var tab_index : int = 0
	for tab in tabs:
		if page_number == tab.flip_to_page: #find the tab with that page num
			break
		tab_index += 1
	return get_tab(tab_index)
