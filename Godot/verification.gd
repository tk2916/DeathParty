#!/usr/bin/env -S godot --headless

# Script for verification.tscn.
# Usage: --scene=PATH
# Automatically loads the default scene for testing and code verification.

extends Node

var timer_load : SceneTreeTimer
var timer_run : SceneTreeTimer
var timer_exit : SceneTreeTimer

var default_scene : String
var scene_path : String
var scene : PackedScene
var root : Node


# Return codes:
# 0 = All checks passed
# 1 = Critical error
# 2 = Warning
var return_code : int = 0



# START OF TESTING CODE

const LOAD_TIME : float = 100.0
const RUN_TIME : float = 100.0
const EXIT_TIME : float = 100.0

func tests() -> void:
	# TODO: Use assert() with current_scene to test functionality
	# Placeholder:
	await get_tree().create_timer(5.0, true, true, true).timeout

# END OF TESTING CODE



func _ready() -> void:
	# Look for scene passed or use default
	default_scene = ProjectSettings.get_setting("application/run/main_scene")
	scene_path = parse_args().get("scene", default_scene)
	
	# No scene
	if !scene_path:
		printerr("Error: No default scene. Pass a scene with --scene=PATH.")
		get_tree().quit(1)
		return
	
	# Set timeout
	timer_load = get_tree().create_timer(LOAD_TIME, true, false, true)
	timer_load.timeout.connect(timeout_load)
	
	# Load scene
	print("Loading scene: " + scene_path + ".")
	#if get_tree().change_scene_to_file(scene_path) != Error.OK:
	#	printerr("Error: Failed to load scene at " + scene_path + ".")
	#	get_tree().quit(1)
	scene = load(scene_path)
	if scene is not PackedScene:
		printerr("Error: Failed to load scene at \"" + scene_path + "\".")
		get_tree().quit(1)
		return
	root = scene.instantiate()
	
	# Run loaded() on ready signal and exited() on exit
	root.tree_exited.connect(exited)
	root.ready.connect(loaded)
	
	# Create tree
	add_child(root)

# Tree loaded
func loaded() -> void:
	# Clear timeout
	timer_load.timeout.disconnect(timeout_load)
	timer_load.timeout.emit()
	timer_load = null
	
	# Set timeout
	timer_run = get_tree().create_timer(RUN_TIME, true, false, true)
	timer_run.timeout.connect(timeout_run)
	
	# Run tests
	print("Scene loaded. Running tests...")
	await tests()
	
	# Clear timeout
	timer_run.timeout.disconnect(timeout_run)
	timer_run.timeout.emit()
	timer_run = null
	
	# Set timeout
	timer_exit = get_tree().create_timer(EXIT_TIME, true, false, true)
	timer_exit.timeout.connect(timeout_exit)
	
	# Free scene
	print("Testing complete. Closing scene...")
	root.queue_free()

# Tree exited
func exited() -> void:
	print("Verification complete! Quitting game...")
	
	# Quit game with notification to remaining nodes
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit(return_code)

# Timeout handlers
func timeout_load() -> void:
	printerr("TIMED OUT: Failed to load scene in {0} seconds.".format([LOAD_TIME]))
	if root is Node:
		root.tree_exited.disconnect(exited)
	get_tree().quit(1)

func timeout_run() -> void:
	printerr("TIMED OUT: Failed to run tests in {0} seconds.".format([RUN_TIME]))
	if root is Node:
		root.tree_exited.disconnect(exited)
	get_tree().quit(1)

func timeout_exit() -> void:
	printerr("TIMED OUT: Failed to exit game in {0} seconds.".format([EXIT_TIME]))
	if root is Node:
		root.tree_exited.disconnect(exited)
	get_tree().quit(2)

# Parse command line args
func parse_args() -> Dictionary[String, String]:
	var arguments : Dictionary[String, String] = {}
	for argument : String in OS.get_cmdline_args():
		# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			var key_value : PackedStringArray = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	return arguments
