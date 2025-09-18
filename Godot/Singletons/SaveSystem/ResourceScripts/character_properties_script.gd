class_name CharacterResource extends TalkingObjectResource

@export var character_location : Globals.SCENES = Globals.SCENES.Everywhere

@export var image_full : CompressedTexture2D
@export var image_polaroid : CompressedTexture2D
@export var image_polaroid_popout : CompressedTexture2D

## SOCIAL MEDIA
@export var image_profile : CompressedTexture2D
@export var profile_tag : String = "@profiletag123"
@export var profile_quote : String = "inspirational quote goes here."
@export var profile_join_date : String = "Month 8, 20XX"
@export var profile_friends : int = 359

signal location_changed
signal interaction_ended
		
func change_location(location_str : String) -> void:
	character_location = Globals.SCENES_STR[location_str]
	location_changed.emit()

func end_chat(_current_conversation : Array[InkLineInfo] = []) -> void:
	super()
	interaction_ended.emit()
	
