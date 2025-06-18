var config = ConfigFile.new()


# audio
var volume: float = 75


func _ready():
	# check if the cfg will load
	var err = config.load("user://settings.cfg")
	
	# if it loads, set each setting to the value from the cfg
	# (or the default if it isnt set in the cfg)
	if err == OK:
		# audio
		volume = config.get_value("audio", "volume", 75)
	
	# if it doesnt load, save a new cfg with the current settings
	else:
		save_settings()


func save_settings():
	config.set_value("audio", "volume", volume)
	config.save("user://settings.cfg")
