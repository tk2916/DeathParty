extends RichTextLabel

@export var color : String = "white"
@export var include_am_pm : bool = true

func update_clock():
	text = "[color="+color+"]"+SaveSystem.get_time_string(include_am_pm)+"[/color]"

func _ready() -> void:
	update_clock()
	SaveSystem.time_changed.connect(update_clock)
