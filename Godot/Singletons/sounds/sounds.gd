extends Node
## singleton with functions for playing one-shot sounds
##
## mostly for short sounds it would be awkward to have as permanent nodes, or
## sounds that get called from scenes as they're freed (which would otherwise get cut off)
##
## i realised i was doing this in a few places with hardcoded preloads which feels a bit
## messy so i wanted to set something up with export vars that could be called in one line
##
## all these scenes pretty much just spawn in, play a sound, then free themself
##
## NOTE: probably not a good way to do sounds that play repeatedly in quick
## succession like dialogue printing sounds, because each sound is an independent
## node so it wont cut off the previous one when played again which can make them
## overlap in an ugly way
##
## if this is the dumbest thing ever (either in concept or in the specific
## way im doing it with functions for each sound etc) let me know lol
##	- jack

@export_group("UI sounds")
@export var journal_close: PackedScene
@export var dialogue_print: PackedScene
@export var phone_typing: PackedScene

@export_group("environment sounds")
@export var door: PackedScene


func play(sound_scene: PackedScene) -> void:
	if sound_scene:
		var sound_instance: FmodEventEmitter3D = sound_scene.instantiate()
		get_tree().current_scene.add_child(sound_instance)


func play_journal_close() -> void:
	play(journal_close)


func play_door() -> void:
	play(door)


func play_dialogue_print() -> void:
	play(dialogue_print)


func play_phone_typing() -> void:
	play(phone_typing)
