class_name TaskResource extends Resource

@export var name : String
@export var description : String
var assigned : bool = false
var finished : bool = false

var gui_node : TaskContainer
var prefab : PackedScene = preload("res://Assets/GUIPrefabs/JournalPrefabs/TaskPrefabs/task_prefab.tscn")

func instantiate() -> TaskContainer:
	assigned = true
	gui_node = prefab.instantiate()
	gui_node.title = self.name
	gui_node.description = self.description
	gui_node.title_label.text = "[color=black]"+name+"[/color]"
	#gui_node.description_label.text = "[color=2b2b2b]"+description+"[/color]"
	return gui_node

func complete():
	finished = true
	print("Task complete: ", name)
