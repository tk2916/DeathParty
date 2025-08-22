## Player emits their location
extends Node
@warning_ignore_start("unused_signal")
signal player_moved(position: Vector3)
signal update_quadrants()
@warning_ignore_restore("unused_signal")
