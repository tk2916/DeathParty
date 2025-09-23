class_name ItemInfoContainer extends InfoContainerGUI

@onready var description_label : RichTextLabel = $DescriptionBacker/Text
	
func set_text(description : String) -> void:
	description_label.text = description
