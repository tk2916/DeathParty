extends Node3D


enum SoundType {ONE_SHOT, SUSTAINED}

@export var sound_type : SoundType
@export var caption_text : String

@onready var label : Label3D = $Offset/Label3D
@onready var animation_player : AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = caption_text


func play():
	if sound_type == SoundType.ONE_SHOT:
		animation_player.play("RESET")
		animation_player.play("fade up")
	elif sound_type == SoundType.SUSTAINED:
		animation_player.play("RESET")
		animation_player.play("buzz")


func stop():
	animation_player.play("fade out")
