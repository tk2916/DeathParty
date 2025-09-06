extends Control


@onready var editable_inputs: Dictionary = Settings.editable_inputs
@onready var list: VBoxContainer = %BindingList
@onready var binding_item_prefab: PackedScene = preload("res://Utilities/pause_menu/input_menu/input_binding_item.tscn")

# TODO: maybe give these clearer names
var button_to_change: Button
var changing_input: bool = false
var current_action: StringName
var current_index: int


func _ready() -> void:
	populate_list()


func populate_list() -> void:
	# loop thru our editable actions in the input map
	for action in editable_inputs.keys():
		# instantiate binding item scene
		# (this is the label and buttons for each binding in the menu)
		var binding_item = binding_item_prefab.instantiate()

		# get references to buttons
		var label_action = binding_item.find_child("ActionName")
		#TODO: give these clearer names like input_a_button
		var input_a = binding_item.find_child("InputA")
		var input_b = binding_item.find_child("InputB")

		# add buttons to group
		# (we're connecting the pressed signal of all nodes in this group to a
		# func that plays UI sfx in pause_menu.gd)
		input_a.add_to_group("buttons")
		input_b.add_to_group("buttons")

		label_action.text = editable_inputs[action]


		# get array of inputs currently bound to this action
		#TODO: probably rename this to 'events' for consistent wording
		var inputs: Array[InputEvent] = InputMap.action_get_events(action)

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

		input_a.pressed.connect(button_pressed.bind(input_a, action, 0))
		input_b.pressed.connect(button_pressed.bind(input_b, action, 1))


func button_pressed(input_button: Button, action: StringName, index: int) -> void:
	if Input.is_action_just_released("remove_input"):
		var events = InputMap.action_get_events(action)
		InputMap.action_erase_event(action, events[index])
		Settings.save_settings()
		input_button.text = "-"
	else:
		#input_button.release_focus()
		button_to_change = input_button
		current_action = action
		current_index = index
		changing_input = true
		button_to_change.text = "AWAITING INPUT"


func _input(event: InputEvent) -> void:
	if changing_input:
		if event is InputEventKey:
			button_to_change.text = event.as_text_keycode()

			Settings.update_binding(current_action, current_index, event)

			changing_input = false

			#button_to_change.grab_focus()

			button_to_change = null

			accept_event()
