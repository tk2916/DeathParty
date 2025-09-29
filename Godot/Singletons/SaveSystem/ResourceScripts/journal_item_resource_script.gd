class_name JournalItemResource extends DefaultResource

@export var texture : CompressedTexture2D
@export var description : String
@export var talking_object_resource : TalkingObjectResource

func refresh() -> void:
	#get the resource from the current save file
	if talking_object_resource:
		talking_object_resource = SaveSystem.get_talking_object(talking_object_resource.name)
