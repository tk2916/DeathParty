class_name TaskDisplayer extends Control

@export var all_tasks_vbox : VBoxContainer
@export var rightpage_title : RichTextLabel
@export var rightpage_description : RichTextLabel

@export var completed_tasks_title : TextureRect

var task_to_node : Dictionary[String, Control] = {}

var address : String = "res://Assets/Resources/TaskResources/"

func set_right_page(title : String, description : String) -> void: #called by task buttons
	rightpage_title.text = title
	rightpage_description.text = description

func new_task(item:String, first_task:bool = false) -> void:
	var task_resource : TaskResource = SaveSystem.task_exists(item)
	var gui_node : TaskContainer = task_resource.instantiate()
	gui_node.task_displayer = self
	all_tasks_vbox.add_child(gui_node)
	all_tasks_vbox.move_child(gui_node, 1)
	task_to_node[item] = gui_node
	if first_task: #display the first task
		set_right_page(task_resource.name, task_resource.description)
		first_task = false

func on_tasks_change(action:String, item:String) -> void:
	if action == "add":
		new_task(item)
	else:
		var task_resource : TaskResource = SaveSystem.task_exists(item)
		task_resource.complete()
		#Move to completed tasks section
		var new_index : int = completed_tasks_title.get_index() + 1
		all_tasks_vbox.move_child(task_to_node[item], new_index)

func _ready() -> void:
	set_right_page("", "")
	SaveSystem.tasks_changed.connect(on_tasks_change)
	
	var first_task : bool = true
	for task : String in SaveSystem.player_data["tasks"]:
		new_task(task, first_task)
		if first_task:
			first_task = false
