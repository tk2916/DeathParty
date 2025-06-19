extends RichTextLabel

func update_clock(key : String, value):
	if key != "time": return
	text = SaveSystem.parse_time(value)

func _ready() -> void:
	#text = SaveSystem.get_key("time")
	update_clock("time", SaveSystem.get_key("time"))
	SaveSystem.stats_changed.connect(update_clock)
