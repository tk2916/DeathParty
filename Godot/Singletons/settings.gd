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
var fullscreen : int = 0
var monitor : int = 0
var vsync : int = 2
var scale : float = 1.0
var upscale : int = 0
var sharpness : float = 0.2
var fps : float = 0.0
var filtering : int = 3
var aa : int = 4
var shadows : int = 3

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
		
		monitor = config.get_value("video", "monitor", monitor)
		apply_monitor(monitor)
		
		vsync = config.get_value("video", "vsync", vsync)
		apply_vsync(vsync)
		
		scale = config.get_value("video", "scale", scale)
		apply_scale(scale)
		
		upscale = config.get_value("video", "upscale", upscale)
		apply_upscale(upscale)
		
		sharpness = config.get_value("video", "sharpness", sharpness)
		apply_sharpness(sharpness)
		
		fps = config.get_value("video", "fps", fps)
		apply_fps(fps)
		
		filtering = config.get_value("video", "filtering", filtering)
		apply_filtering(filtering)
		
		aa = config.get_value("video", "aa", aa)
		apply_aa(aa)
		
		shadows = config.get_value("video", "shadows", shadows)
		apply_shadows(shadows)

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
	config.set_value("video", "scale", scale)
	config.set_value("video", "upscale", upscale)
	config.set_value("video", "sharpness", sharpness)
	config.set_value("video", "vsync", vsync)
	config.set_value("video", "fps", fps)

	config.set_value("video", "filtering", filtering)
	config.set_value("video", "aa", aa)
	config.set_value("video", "shadows", shadows)

	# audio
	config.set_value("audio", "volume", volume)

	config.save("user://settings.cfg")


func load_bindings() -> void:
	for action : StringName in editable_inputs.keys():
		# TODO: maybe make the fallback something better than an empty string

		# OR MAYBE NOT, since default binds are in the project settings, so
		# maybe binds dont need proper fallbacks like other settings
		var physical_key_codes : Array[Key]
		physical_key_codes.assign(config.get_value("input", action, []))

		if physical_key_codes.size() > 0:
			InputMap.action_erase_events(action)

			for code : Key in physical_key_codes:
				var event := InputEventKey.new()
				event.physical_keycode = code
				InputMap.action_add_event(action, event)


func update_binding(action : StringName, index : int, new_event : InputEvent) -> void:
	# get current events for this action
	var events : Array[InputEvent] = InputMap.action_get_events(action)

	# erase the event at the index of our new event
	InputMap.action_erase_event(action, events[index])

	# overwrite the event with our new event
	InputMap.action_add_event(action, new_event)

	save_settings()


func save_bindings() -> void:
	for action : StringName in editable_inputs.keys():
		var events : Array[InputEvent] = InputMap.action_get_events(action)
		var physical_key_codes : Array = []

		for event : InputEvent in events:
			if event is InputEventKey:
				var event_key : InputEventKey = event
				physical_key_codes.append(event_key.physical_keycode)

		# TODO: make these save as more user-readable values like key names
		# instead of the physical keycodes (maybe a later optimisation lol)
		config.set_value("input", action, physical_key_codes)


func apply_fullscreen(mode : int) -> void:
	match mode:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


func set_fullscreen(mode : int) -> void:
	fullscreen = mode
	apply_fullscreen(fullscreen)
	save_settings()


func apply_monitor(screen : int) -> void:
	DisplayServer.window_set_current_screen(screen)


func set_monitor(screen : int) -> void:
	monitor = screen
	apply_monitor(monitor)
	save_settings()


func apply_vsync(mode : int) -> void:
	match mode:
		0:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		1:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		2:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)


func set_vsync(mode : int) -> void:
	vsync = mode
	apply_vsync(vsync)
	save_settings()


func apply_scale(value : float) -> void:
	get_viewport().scaling_3d_scale = value


func set_scale(value : float) -> void:
	scale = value
	apply_scale(scale)
	save_settings()


func apply_upscale(mode : int) -> void:
	match mode:
		0:
			get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		1:
			get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
		2:
			get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2


func set_upscale(mode : int) -> void:
	upscale = mode
	apply_upscale(upscale)
	save_settings()


func apply_sharpness(value : float) -> void:
	get_viewport().fsr_sharpness = 2.0 - value


func set_sharpness(value : float) -> void:
	sharpness = value
	apply_sharpness(sharpness)
	save_settings()


func apply_fps(cap : float) -> void:
	Engine.max_fps = floor(cap)


func set_fps(cap : float) -> void:
	fps = cap
	apply_fps(fps)
	save_settings()


func apply_filtering(mode : int) -> void:
	match mode:
		0:
			get_viewport().set_anisotropic_filtering_level(Viewport.ANISOTROPY_DISABLED)
		1:
			get_viewport().set_anisotropic_filtering_level(Viewport.ANISOTROPY_2X)
		2:
			get_viewport().set_anisotropic_filtering_level(Viewport.ANISOTROPY_4X)
		3:
			get_viewport().set_anisotropic_filtering_level(Viewport.ANISOTROPY_8X)
		4:
			get_viewport().set_anisotropic_filtering_level(Viewport.ANISOTROPY_16X)


func set_filtering(mode : int) -> void:
	filtering = mode
	apply_filtering(filtering)
	save_settings()


func apply_aa(mode : int) -> void:
	# disable all anti-aliasing solutions
	get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	get_viewport().use_taa = false
	get_viewport().msaa_3d = Viewport.MSAA_DISABLED

	# enable the selected solution
	match mode:
		0:
			pass
		1:
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		2:
			get_viewport().use_taa = true
		3:
			get_viewport().msaa_3d = Viewport.MSAA_2X
		4:
			get_viewport().msaa_3d = Viewport.MSAA_4X
		5:
			get_viewport().msaa_3d = Viewport.MSAA_8X


func set_aa(mode : int) -> void:
	aa = mode
	apply_aa(aa)
	save_settings()


func apply_shadows(level : int) -> void:
	if level == 0: # Very Low
		# Shadow size
		RenderingServer.directional_shadow_atlas_set_size(1024, true)
		#directional_light.shadow_bias = 0.04
		get_viewport().positional_shadow_atlas_size = 1024
		
		# Shadow filtering
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
	elif level == 1: # Low
		# Shadow size
		RenderingServer.directional_shadow_atlas_set_size(2048, true)
		#directional_light.shadow_bias = 0.03
		get_viewport().positional_shadow_atlas_size = 2048
		
		# Shadow filtering
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
	elif level == 2: # Medium
		# Shadow size
		RenderingServer.directional_shadow_atlas_set_size(4096, true)
		#directional_light.shadow_bias = 0.02
		get_viewport().positional_shadow_atlas_size = 4096
		
		# Shadow filtering
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
	elif level == 3: # High
		# Shadow size
		RenderingServer.directional_shadow_atlas_set_size(8192, true)
		#directional_light.shadow_bias = 0.01
		get_viewport().positional_shadow_atlas_size = 8192
		
		# Shadow filtering
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
	elif level == 4: # Ultra
		# Shadow size
		RenderingServer.directional_shadow_atlas_set_size(16384, true)
		#directional_light.shadow_bias = 0.005
		get_viewport().positional_shadow_atlas_size = 16384
		
		# Shadow filtering
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
		RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)


func set_shadows(level : int) -> void:
	shadows = level
	apply_shadows(shadows)
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
