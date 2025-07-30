class_name TaskContainer extends ThreeDGUI

@export var title_label : RichTextLabel
@export var button : Button

var task_displayer : TaskDisplayer
var task_resource : TaskResource

##INHERITED
func on_mouse_down():
	task_displayer.set_right_page(task_resource.name, task_resource.description, task_resource.time_updated)
	
func enter_hover():
	super()
	$Highlight.visible = true
	
func exit_hover():
	super()
	$Highlight.visible = false
