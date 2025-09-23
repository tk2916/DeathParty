##This script helps assign focus to ui menus once the keyboard/controller is used
extends  Node

#References to the menu button that correspond to the cardinal directions in a given ui menu
var left_button: Button
var right_button: Button
var up_button: Button
var down_button: Button

#While a choice is waiting, will register ui inputs and grab the focus of the appropriate button 
func _process(_delta: float) -> void:
	if !DialogueSystem.are_choices: return
	
	if Input.is_action_just_pressed("move_left"):
		if left_button != null:
			left_button.grab_focus()
			
	if Input.is_action_just_pressed("move_right"):
		if right_button != null:
			right_button.grab_focus()
			
	if Input.is_action_just_pressed("move_up"):
		if up_button != null:
			up_button.grab_focus()
			
	if Input.is_action_just_pressed("move_down"):
		if down_button != null:
			down_button.grab_focus()

## Assigns choice buttons for the menu focus grabber to listen to when pressing the appropriate cardinal direction.
## NOTE: For any unneeded buttons, please assign "null".
func assign_buttons(left_bt: Button, right_bt: Button, up_bt: Button, down_bt: Button) -> void:
	left_button = left_bt
	right_button = right_bt
	up_button = up_bt
	down_button = down_bt
	#region Debug printings. Can be enabled for menu focus testing before visuals are implamented
	#if left_button != null: print(left_button.name + " Has been assigned as left button")
	#if right_button != null: print(right_button.name + " Has been assigned as right button")
	#if up_button != null: print(up_button.name + " Has been assigned as up button")
	#if down_button != null: print(down_button.name + " Has been assigned as down button")
	#endregion
