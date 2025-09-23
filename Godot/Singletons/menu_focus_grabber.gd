#This script helps assign focus to ui menus once the keyboard/controller is used
extends Node

#References to the menu button that correspond to the cardinal directions in a given ui menu
var left_button: Button
var right_button: Button
var up_button: Button
var down_button: Button
var listen_to_ui_inputs: bool = false

func _ready() -> void:
	GuiSystem.guis_closed.connect(reset_focus_grabber)

## Prepares the script to repopulate with a new menu's layout.
func reset_focus_grabber() -> void:
	left_button = null
	right_button = null
	up_button = null
	down_button = null
	listen_to_ui_inputs = false

#While marked for listening, will register ui inputs and grab the focus of the appropriate button, and unmark for listening 
func _process(delta: float) -> void:
	if !listen_to_ui_inputs: return
	
	if Input.is_action_just_pressed("ui_left"):
		if left_button != null:
			left_button.grab_focus()
			print("Left button focus grabbed")
			reset_focus_grabber()
			
	if Input.is_action_just_pressed("ui_right"):
		if right_button != null:
			right_button.grab_focus()
			print("Right button focus grabbed")
			reset_focus_grabber()
			
	if Input.is_action_just_pressed("ui_up"):
		if up_button != null:
			up_button.grab_focus()
			print("Up button focus grabbed")
			reset_focus_grabber()
			
	if Input.is_action_just_pressed("ui_down"):
		if down_button != null:
			down_button.grab_focus()
			print("Down button focus grabbed")
			reset_focus_grabber()

## Assigns cardinal buttons for the menu focus grabber to listen to when pressing the appropriate cardinal direction.
## NOTE: For any unneeded buttons, please assign "null".
func assign_buttons(left_bt: Button, right_bt: Button, up_bt: Button, down_bt: Button) -> void:
	left_button = left_bt
	right_button = right_bt
	up_button = up_bt
	down_button = down_bt
	listen_to_ui_inputs = true
	#region Debug printings. Can be enabled for menu focus testing before visuals are implamented
	if left_button != null: print(left_button.name + " Has been assigned as left button")
	if right_button != null: print(right_button.name + " Has been assigned as right button")
	if up_button != null: print(up_button.name + " Has been assigned as up button")
	if down_button != null: print(down_button.name + " Has been assigned as down button")
	#endregion
