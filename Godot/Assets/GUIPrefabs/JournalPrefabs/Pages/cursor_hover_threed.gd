class_name ThreeDCursorHover extends ThreeDGUI

##INHERITED
func enter_hover() -> void:
	super()
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	
func exit_hover() -> void:
	super()
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
