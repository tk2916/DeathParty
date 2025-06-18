extends Node


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
		set_volume(volume)
	
	# if it doesnt load, save a new cfg with the current settings
	else:
		save_settings()


func save_settings():
	config.set_value("audio", "volume", volume)
	config.save("user://settings.cfg")


func set_volume(value):
	var bus = FmodServer.get_bus("bus:/")
	
	# i think the volume for the bus goes from 0 to 1, so im dividing the
	# slider percentage by 100 - it might not actually work like that though lol
	bus.set_volume(value / 100)
	
	volume = value
	
	save_settings()
