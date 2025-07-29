class_name TaskContainer extends ThreeDGUI

@export var title_label : RichTextLabel
@export var button : Button

var task_displayer : TaskDisplayer
var title : String
var description : String
	
#func _input(event) -> void:
	#print("Input received: ", event)
func on_mouse_down():
	print("Clicked Task container!")
	task_displayer.set_right_page(title, description)
	
func enter_hover():
	super()
	$Highlight.visible = true
	
func exit_hover():
	super()
	$Highlight.visible = false
