# TODO: add static return types for funcs
# TODO: set fallback values to use declared values from top of script

extends Node


var config : ConfigFile = ConfigFile.new()

# audio
var volume : float = 50

# video
var fullscreen : bool = false


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

		# audio
		volume = config.get_value("audio", "volume", 75)
		apply_volume(volume)

		# video
		fullscreen = config.get_value("video", "fullscreen", false)
		apply_fullscreen(fullscreen)


	# if it doesnt load, print error and create new cfg with current settings
	else:
		print("failed to load settings.cfg (" + error_string(err) + ")")
		print("creating new settings.cfg file with default settings . . .")
		save_settings()


func save_settings() -> void:
	# audio
	config.set_value("audio", "volume", volume)

	# video
	config.set_value("video", "fullscreen", fullscreen)

	config.save("user://settings.cfg")


func apply_volume(value : float) -> void:
	var bus : FmodBus = FmodServer.get_bus("bus:/")
	
	# i think the volume for the bus goes from 0 to 1, so im dividing the
	# slider percentage by 100 - might not actually work like that though lol
	bus.set_volume(value / 100)


func set_volume(value : float) -> void:
	volume = value
	apply_volume(value)
	save_settings()


func apply_fullscreen(enabled : bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func set_fullscreen(enabled : bool) -> void:
	fullscreen = enabled
	apply_fullscreen(enabled)
	save_settings()
