extends ScrollContainer
var max_scroll_length = 0

var hovering : bool = false
var holding_click : bool = false
	
@onready var scrollbar : VScrollBar = self.get_v_scroll_bar()
func _ready():
	scrollbar.connect("changed", handle_scrollbar_changed)
	max_scroll_length = scrollbar.max_value    #autoscroll to bottom
	
func handle_scrollbar_changed():
	if max_scroll_length != scrollbar.max_value:
		max_scroll_length = scrollbar.max_value
		scroll_vertical = max_scroll_length

func _on_touch_screen_mouse_entered() -> void:
	print("Hovering true")
	hovering = true

func _on_touch_screen_mouse_exited() -> void:
	print("Hovering false")
	hovering = false

func scroll(delta : float):
	var cur_scroll_value = get_v_scroll()
	print("delta", delta, " ", cur_scroll_value)
	var difference = -2*delta
	var new_val = cur_scroll_value+difference
	new_val = clamp(new_val, 0, scrollbar.max_value)
	set_v_scroll(new_val)

#click and drag to scroll (like on phone)
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and holding_click:
		var delta = event.relative
		scroll(delta.y)
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed == true and hovering:
				holding_click = true
			else: 
				holding_click = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll(10)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll(-10)
