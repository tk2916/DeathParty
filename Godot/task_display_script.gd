class_name TaskDisplayer extends Control

@export var all_tasks_vbox : VBoxContainer
@export var rightpage_title : RichTextLabel
@export var rightpage_description : RichTextLabel

var address : String = "res://Assets/Resources/TaskResources/"

func set_right_page(title : String, description : String) -> void: #called by task buttons
	rightpage_title.text = "[color=black]"+title+"[/color]"
	rightpage_description.text = "[color=black]"+description+"[/color]"

func new_task(item:String) -> void:
	var task_resource : TaskResource = SaveSystem.task_exists(item)
	var gui_node : TaskContainer = task_resource.instantiate()
	all_tasks_vbox.add_child(gui_node)

func on_tasks_change(action:String, item:String) -> void:
	if action == "add":
		new_task(item)
	else:
		var task_resource = SaveSystem.task_exists(item)
		task_resource.complete()

func _ready() -> void:
	SaveSystem.tasks_changed.connect(on_tasks_change)
	for task in SaveSystem.player_data["tasks"]:
		new_task(task)
