extends RichTextLabel

@export var color : String = "white"

func update_clock():
	text = "[color="+color+"]"+SaveSystem.get_time_string()+"[/color]"

func _ready() -> void:
	#text = SaveSystem.get_key("time")
	update_clock()
	SaveSystem.time_changed.connect(update_clock)
