extends Node

@export var json_file : JSON
@export var json_file2 : JSON
@export var message_box : Control
	
func _ready() -> void:
	DialogueSystem.to_phone(json_file, "Caleb, Rowan, Nora, You")
	DialogueSystem.to_phone(json_file2, "Caleb")
	SaveSystem.add_task("First task")
	SaveSystem.add_task("Second Task")
	SaveSystem.add_task("A third task")
