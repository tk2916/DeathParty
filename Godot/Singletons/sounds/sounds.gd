extends Node
## singleton with functions for playing one-shot sounds
##
## mostly for short sounds it would be awkward to have as permanent nodes in another scene, or
## sounds that get called from scenes as they're freed (which would otherwise get cut off)
##
## i realised i was doing this in a few places with hardcoded preloads which feels a bit
## messy so i wanted to set something cleaner up which could be called in one line and wont
## have references which could get easily broken
##
## all these export scenes pretty much just spawn in, play a sound, then free themself,
## (the emitters in this global scene are used for sounds which play
## repeatedly and so need to come from one consistent emitter to stop them overlapping)
##
## if this is the dumbest thing ever (either in concept or in the specific
## way im doing it with functions for each sound etc) let me know lol
##	- jack

@export_group("UI sounds")
@export var journal_close: PackedScene
@export var phone_typing: PackedScene

@export_group("environment sounds")
@export var door: PackedScene

@onready var dialogue_print: FmodEventEmitter3D = %DialoguePrint


func play(sound_scene: PackedScene) -> void:
	if sound_scene:
		var sound_instance: FmodEventEmitter3D = sound_scene.instantiate()
		get_tree().current_scene.add_child(sound_instance)


func play_journal_close() -> void:
	play(journal_close)


func play_door() -> void:
	play(door)


func play_phone_typing() -> void:
	play(phone_typing)


func play_dialogue_print() -> void:
	dialogue_print.play()