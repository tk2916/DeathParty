class_name TaskContainer extends ThreeDGUI

@export var title_label : RichTextLabel
@export var highlight : Control

var task_displayer : TaskDisplayer
var task_resource : TaskResource

##INHERITED
func on_mouse_down() -> void:
	task_displayer.set_right_page(task_resource.name, task_resource.description)
	
func enter_hover() -> void:
	super()
	highlight.visible = true
	
func exit_hover() -> void:
	super()
	highlight.visible = false
