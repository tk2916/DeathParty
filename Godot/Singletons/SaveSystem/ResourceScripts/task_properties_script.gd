class_name TaskResource extends DefaultResource

@export var description : String
var assigned : bool = false
var finished : bool = false

var time_updated : float

var gui_node : TaskContainer
var prefab : PackedScene = preload("res://Assets/GUIPrefabs/JournalPrefabs/TaskPrefabs/task_prefab.tscn")

func instantiate() -> TaskContainer:
	assigned = true
	time_updated = SaveSystem.get_key("time")
	gui_node = prefab.instantiate()
	gui_node.task_resource = self
	gui_node.title_label.text = "[color=black]"+name+"[/color]"
	#gui_node.description_label.text = "[color=2b2b2b]"+description+"[/color]"
	return gui_node

func update() -> void:
	time_updated = SaveSystem.get_key("time")

func complete() -> void:
	finished = true
	print("Task complete: ", name)
