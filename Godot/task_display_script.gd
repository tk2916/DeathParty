extends VBoxContainer

@export var vbox : VBoxContainer

var address : String = "res://Assets/Resources/TaskResources/"

func new_task(item:String):
	var task_resource = SaveSystem.task_exists(item)
	var gui_node = task_resource.instantiate()
	vbox.add_child(gui_node)

func on_tasks_change(action:String, item:String):
	if action == "add":
		new_task(item)
	else:
		var task_resource = SaveSystem.task_exists(item)
		task_resource.complete()

func _ready() -> void:
	SaveSystem.tasks_changed.connect(on_tasks_change)
	for task in SaveSystem.player_data["tasks"]:
		new_task(task)
