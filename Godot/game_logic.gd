extends Node

var EXAMPLE_FILE : String = "res://InkExamples/example.ink5.json"

func _ready():
	DialogueSystem.setDialogueBox(2)
	SaveSystem.set_variable("set_this_to_true", true)
	DialogueSystem.from_JSON(EXAMPLE_FILE)
	
	
	#SaveSystem.edit("name", "kiki")
	#SaveSystem.save()
