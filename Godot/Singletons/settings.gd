extends Node


var config : ConfigFile = ConfigFile.new()

# input

# TODO: maybe make these keys StringNames by prefixing '&' before quotes
# e.g. &"move_left" - i think this might make things faster since i think
# its converting these to StringNames down the line when update_binding is called
# since input map action names are StringNames (while these dictionary keys are
# just strings) I DOUBT THIS MATTERS MUCH FOR PERFORMANCE THO LOL
var editable_inputs : Dictionary = {
	"move_left" : "Left",
	"move_right" : "Right",
	"move_up" : "Up",
	"move_down" : "Down",
	"interact" : "Interact"
}

# video
var fullscreen : int = DisplayServer.WINDOW_MODE_WINDOWED

# audio
var volume : float = 50


func _ready() -> void:
	# check if the cfg will load
	var err : Error = config.load("user://settings.cfg")
	print("loading settings.cfg . . .")

	# if it loads, apply each setting with the values from the cfg
	# (or a fallback if it isnt set in the cfg)
	# if we think its simpler to apply most settings from elsewhere then we can
	# move this to the pause menu script and have this singleton just read and
	# set cfg values and not handle any logic
	if err == OK:
		print("settings.cfg loaded successfully")

		# input
		load_bindings()

		# video
		fullscreen = config.get_value("video", "fullscreen", fullscreen)
		apply_fullscreen(fullscreen)

		# audio
		volume = config.get_value("audio", "volume", volume)
		apply_volume(volume)

	# if it doesnt load, print error and create new cfg with current settings
	else:
		print("failed to load settings.cfg (" + error_string(err) + ")")
		print("creating new settings.cfg file with default settings . . .")
		save_settings()


func save_settings() -> void:

	# input
	save_bindings()

	# video
	config.set_value("video", "fullscreen", fullscreen)

	# audio
	config.set_value("audio", "volume", volume)

	config.save("user://settings.cfg")


func load_bindings() -> void:
	for action in editable_inputs.keys():
		# TODO: maybe make the fallback something better than an empty string

		# OR MAYBE NOT, since default binds are in the project settings, so
		# maybe binds dont need proper fallbacks like other settings
		var physical_key_codes = config.get_value("input", action, [])

		if physical_key_codes.size() > 0:
			InputMap.action_erase_events(action)

			for code in physical_key_codes:
				var event = InputEventKey.new()
				event.physical_keycode = code
				InputMap.action_add_event(action, event)


func update_binding(action : StringName, index : int, new_event : InputEvent) -> void:
	# get current events for this action
	var events = InputMap.action_get_events(action)

	# erase the event at the index of our new event
	InputMap.action_erase_event(action, events[index])

	# overwrite the event with our new event
	InputMap.action_add_event(action, new_event)

	save_settings()


func save_bindings() -> void:
	for action in editable_inputs.keys():
		var events = InputMap.action_get_events(action)
		var physical_key_codes : Array = []

		for event in events:
			if event is InputEventKey:
				physical_key_codes.append(event.physical_keycode)

		# TODO: make these save as more user-readable values like key names
		# instead of the physical keycodes (maybe a later optimisation lol)
		config.set_value("input", action, physical_key_codes)


func apply_fullscreen(mode : int) -> void:
	DisplayServer.window_set_mode(mode)


func set_fullscreen(mode : int) -> void:
	match mode:
		0:
			fullscreen = DisplayServer.WINDOW_MODE_WINDOWED
		1:
			fullscreen = DisplayServer.WINDOW_MODE_FULLSCREEN
		2:
			fullscreen = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	apply_fullscreen(fullscreen)
	save_settings()


func apply_volume(value : float) -> void:
	var bus : FmodBus = FmodServer.get_bus("bus:/")

	# i think the volume for the bus goes from 0 to 1, so im dividing the
	# slider percentage by 100 - might not actually work like that though lol
	bus.set_volume(value / 100)


func set_volume(value : float) -> void:
	volume = value
	apply_volume(volume)
	save_settings()
