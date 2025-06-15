extends ScrollContainer
#set_deferred("scroll_vertical", get_v_scroll_bar().max_value)
var max_scroll_length = 0
	
@onready var scrollbar = self.get_v_scroll_bar()
func _ready():
	scrollbar.connect("changed",handle_scrollbar_changed)
	max_scroll_length = scrollbar.max_value    #autoscroll to bottom
func handle_scrollbar_changed():
	if max_scroll_length != scrollbar.max_value:
		max_scroll_length = scrollbar.max_value
		scroll_vertical = max_scroll_length
