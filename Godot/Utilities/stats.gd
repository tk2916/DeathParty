class_name StatsDisplay
extends CanvasLayer

var enabled : bool = false
var mode : int
var counter : float = 0.0

@onready var fps_label : Label = $FPSLabel

func _ready() -> void:
	init()

func _process(delta : float) -> void:
	counter += delta
	#print(counter)
	# Hide FPS label until it's initially updated by the engine (this can take up to 1 second).
	#fps_label.visible = counter >= 1.0
	#fps_label.text = "%d FPS (%.2f mspf)" % [Engine.get_frames_per_second(), 1000.0 / Engine.get_frames_per_second()]
	fps_label.text = "FPS: %d" % [Engine.get_frames_per_second()]
	# Color FPS counter depending on framerate.
	# The Gradient resource is stored as metadata within the FPSLabel node (accessible in the inspector).
	fps_label.modulate = fps_label.get_meta("gradient").sample(remap(Engine.get_frames_per_second(), 0, 180, 0.0, 1.0))

func init() -> void:
	set_mode(Settings.stats)

func set_mode(value : int) -> void:
	mode = value
	enabled = mode > 0
	set_visible(enabled)
	set_process(enabled)
