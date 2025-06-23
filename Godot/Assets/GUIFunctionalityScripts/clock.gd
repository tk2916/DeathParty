extends RichTextLabel

@export var color : String = "white"

func update_clock(key : String, value):
	if key != "time": return
	text = "[color="+color+"]"+SaveSystem.parse_time(value)+"[/color]"

func _ready() -> void:
	#text = SaveSystem.get_key("time")
	update_clock("time", SaveSystem.get_key("time"))
	SaveSystem.stats_changed.connect(update_clock)
