#!/usr/bin/env -S godot --headless --verbose --script
extends SceneTree

const SCENE_PATH := "res://main.tscn"

var scene : PackedScene = preload(SCENE_PATH)

func _init() -> void:
	print("Verifying! Base scene: " + SCENE_PATH)
	# Possible to load global autoload singletons?
	#var save_system: Object = load("res://Singletons/SaveSystem/save_system.gd").new()
	#Engine.register_singleton("SaveSystem", save_system)
	change_scene_to_packed(scene)
	node_removed.connect(quit.bind(current_scene))
	current_scene.ready.connect(scene_ready)
	quit()

func scene_ready() -> void:
	unload_current_scene()
