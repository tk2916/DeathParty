class_name TaskDisplayer extends Control

@export var all_tasks_vbox : VBoxContainer
@export var rightpage_title : RichTextLabel
@export var rightpage_description : RichTextLabel
@export var rightpage_time : RichTextLabel

var address : String = "res://Assets/Resources/TaskResources/"

func set_right_page(title : String, description : String, time : float) -> void: #called by task buttons
	rightpage_title.text = "[color=black]"+title+"[/color]"
	rightpage_description.text = "[color=black]"+description+"[/color]"
	if time != -1:
		rightpage_time.text = "[color=black]"+SaveSystem.parse_time(time)+"[/color]"

func new_task(item:String, first_task:bool = false) -> void:
	var task_resource : TaskResource = SaveSystem.task_exists(item)
	var gui_node : TaskContainer = task_resource.instantiate()
	gui_node.task_displayer = self
	all_tasks_vbox.add_child(gui_node)
	if first_task: #display the first task
		set_right_page(task_resource.name, task_resource.description, task_resource.time_updated)
		first_task = false

func on_tasks_change(action:String, item:String) -> void:
	if action == "add":
		new_task(item)
	else:
		var task_resource : TaskResource = SaveSystem.task_exists(item)
		task_resource.complete()

func _ready() -> void:
	set_right_page("", "", -1)
	SaveSystem.tasks_changed.connect(on_tasks_change)
	
	var first_task : bool = true
	for task : String in SaveSystem.player_data["tasks"]:
		new_task(task, first_task)
		if first_task:
			first_task = false
