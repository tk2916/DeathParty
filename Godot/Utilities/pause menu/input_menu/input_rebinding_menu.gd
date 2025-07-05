extends Control


@onready var editable_inputs : Dictionary = Settings.editable_inputs
@onready var list : VBoxContainer = %BindingList
@onready var binding_item_prefab : PackedScene = preload("res://Utilities/pause menu/input_menu/input_binding_item.tscn")

# TODO: maybe give these clearer names
var button_to_change : Button
var changing_input : bool = false
var current_action : StringName
var current_index : int


func _ready() -> void:
	populate_list()


func populate_list() -> void:
	# loop thru actions in map
	for action in editable_inputs.keys():
		# instantiate binding item scene
		var binding_item = binding_item_prefab.instantiate()

		# get references to control nodes in scene
		var label_action = binding_item.find_child("ActionName")
		#TODO: give these clearer names like input_a_button
		var input_a = binding_item.find_child("InputA")
		var input_b = binding_item.find_child("InputB")

		label_action.text = editable_inputs[action]

		# get array of inputs currently bound to this action
		#TODO: probably rename this to 'events' for consistent wording
		var inputs : Array[InputEvent] = InputMap.action_get_events(action)

		if inputs.size() == 0:
			input_a.text = "-"
			input_b.text = "-"
		elif inputs.size() == 1:
			input_a.text = inputs[0].as_text().trim_suffix(" (Physical)")
			input_b.text = "-"
		elif inputs.size() > 1:
			input_a.text = inputs[0].as_text().trim_suffix(" (Physical)")
			input_b.text = inputs[1].as_text().trim_suffix(" (Physical)")

		list.add_child(binding_item)

		input_a.pressed.connect(button_pressed.bind(input_a,action,0))
		input_b.pressed.connect(button_pressed.bind(input_b,action,1))


func button_pressed(input_button : Button, action : StringName, index : int) -> void:
	if Input.is_action_just_released("remove_input"):
		var events = InputMap.action_get_events(action)
		InputMap.action_erase_event(action, events[index])
		Settings.save_settings()
		input_button.text = "-"
	else:
		button_to_change = input_button
		current_action = action
		current_index = index
		changing_input = true


func _input(event : InputEvent) -> void:
	if changing_input:
		if event is InputEventKey:
			button_to_change.text = event.as_text_keycode()

			Settings.update_binding(current_action, current_index, event)

			button_to_change = null

			#TODO: stop this from causing crashes if player
			# exits menu during binding
			changing_input = false
