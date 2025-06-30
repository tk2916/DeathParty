extends Control


@onready var list : VBoxContainer = %BindingList
@onready var binding_item_prefab : PackedScene = preload("res://input_binding_item.tscn")

@onready var editable_inputs : Dictionary = {
	"move_left" : "Left",
	"move_right" : "Right",
	"move_up" : "Up",
	"move_down" : "Down",
	"jump" : "Jump",
	"interact" : "Interact"
}

var button_to_change : Button
var action_input_to_change : InputEvent
var changing_input : bool = false


func _ready() -> void:
	populate_list()


func populate_list() -> void:
	InputMap.load_from_project_settings()
	for action in InputMap.get_actions():
		if !editable_inputs.has(action):
			continue
		var binding_item = binding_item_prefab.instantiate()
		var label_action = binding_item.find_child("ActionName")
		var input_a = binding_item.find_child("InputA")
		var input_b = binding_item.find_child("InputB")
		label_action.text = editable_inputs[action]
		var inputs : Array[InputEvent] = InputMap.action_get_events(action)

		if inputs.size() == 0:
			input_a.text = "-"
			input_b.text = "-"
		elif inputs.size() == 1:
			if inputs.size() == 1:
				input_a.text = inputs[0].as_text().trim_suffix(" (Physical)")
				input_b.text = "-"
		elif inputs.size() > 1:
			input_a.text = inputs[0].as_text().trim_suffix(" (Physical)")
			input_b.text = inputs[1].as_text().trim_suffix(" (Physical)")

		list.add_child(binding_item)
		input_a.pressed.connect(button_pressed.bind(input_a,action,0))
		input_b.pressed.connect(button_pressed.bind(input_b,action,1))


func button_pressed(input_button,action,index) -> void:
	if Input.is_action_just_released("remove_input"):
		remove_input(action,index)
		input_button.text = "-"
	else:
		button_to_change = input_button
		action_input_to_change = InputMap.action_get_events(action)[index]
		changing_input = true


func remove_input(action,index) -> void:
	InputMap.action_get_events(action)[index].physical_keycode = Key.KEY_NONE
	InputMap.action_get_events(action)[index].keycode = Key.KEY_NONE


func add_input(action,index) -> void:
	var action_inputs = InputMap.action_get_events(action)[index]
	#if action_inputs.size > index:
		
	#else:
		


func _input(event) -> void:
	if changing_input:
		if event is InputEventKey:
			button_to_change.text = event.as_text_keycode()
			action_input_to_change.keycode = event.keycode
			action_input_to_change.physical_keycode = event.keycode
			button_to_change = null
			action_input_to_change = null
			changing_input = false
