extends Node

@export var json_file : JSON

@export var json_file2 : JSON
@export var message_box : Control

@export var test_inventory_item : Node3D

#func _init() -> void:
	#ContentLoader.finished_loading.connect(func():
		#ContentLoader.direct_teleport_player("Library"))

func _ready() -> void:
	pass
	# SaveSystem.add_task("Second Task")
	# SaveSystem.add_task("A third task")
	# SaveSystem.add_task("A third task")
	# SaveSystem.add_task("Second Task")
	# SaveSystem.add_task("Second Task")
	# SaveSystem.add_task("Second Task")
	# SaveSystem.add_task("Second Task")
	# #SaveSystem.add_task("Second Task")
	
	# SaveSystem.add_item("Nora's Polaroid")
	# SaveSystem.add_item("Olivia's Polaroid")
	# SaveSystem.add_item("Scissors")
	# SaveSystem.add_item("Pill Bottle")
	#SaveSystem.add_item("Polaroid Camera")
	#SaveSystem.add_item("ID Card")

	#print("PARSING JSON -----", InkParser.parse(json_file).containers["root"].tostring())
	
	#SaveSystem.create_new_item("TestItem", "", test_inventory_item)
	#SaveSystem.add_item("TestItem")
