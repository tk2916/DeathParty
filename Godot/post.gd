class_name Post extends Control

@export var social_media_app : SocialMediaApp
@export var button : Button
@export var character_resource : CharacterResource

func _ready() -> void:
	button.pressed.connect(social_media_app.on_user_pressed.bind(character_resource))
