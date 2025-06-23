extends Node

@export var json_file : JSON

@export var json_file2 : JSON
@export var message_box : Control
	
func _ready() -> void:
	DialogueSystem.to_phone("Caleb, Rowan, Nora, You", json_file)
	DialogueSystem.to_phone("Caleb", json_file2)
	SaveSystem.add_task("First task")
	SaveSystem.add_task("Second Task")
	SaveSystem.add_task("A third task")
