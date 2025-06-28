extends Node


var config = ConfigFile.new()

# audio
var volume : float = 50

# video
var fullscreen : bool = false


func _ready():
	# check if the cfg will load
	var err = config.load("user://settings.cfg")

	# if it loads, set each setting to the value from the cfg
	# (or the default if it isnt set in the cfg)
	# if we think its simpler to set most settings from elsewhere then we can
	# move this to the pause menu script and have this singleton just read and
	# set cfg values and not handle any logic
	if err == OK:
		# audio
		volume = config.get_value("audio", "volume", 75)
		set_volume(volume)

		# video
		fullscreen = config.get_value("video", "fullscreen", false)
		set_fullscreen(fullscreen)


	# if it doesnt load, save a new cfg with the current settings
	else:
		save_settings()


func save_settings():
	# audio
	config.set_value("audio", "volume", volume)

	# video
	config.set_value("video", "fullscreen", fullscreen)

	config.save("user://settings.cfg")


func set_volume(value : float):
	var bus : FmodBus = FmodServer.get_bus("bus:/")

	# i think the volume for the bus goes from 0 to 1, so im dividing the
	# slider percentage by 100 - it might not actually work like that though lol
	bus.set_volume(value / 100)

	# this doesnt do anything on the initial set_volume in _ready() (i think)
	# but when you call this func by changing volume in the settings menu this
	# writes it to the cfg and saves it - if this is weird we can break it into
	# 2 different functions like set_initial_volume() and set_volume() but 
	# keeping them together felt neater for now
	volume = value
	save_settings()


func set_fullscreen(enabled : bool):
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif not enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 

	fullscreen = enabled
	save_settings()
