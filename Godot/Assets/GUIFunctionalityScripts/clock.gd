extends RichTextLabel

func update_clock(key : String, value):
	if key == "time":
		var am_pm : String = " a.m."
		var hour : int = int(value)
		var minutes : int = int((value - hour)*60) #isolate decimal
		var mins_string : String = str(minutes)
		if hour > 12:
			hour -= 12
			am_pm = " p.m."
		
		if minutes == 0:
			mins_string = "00"
		elif minutes < 10:
			mins_string = "0"+mins_string
		
		text = str(hour) + ":" + mins_string + am_pm

func _ready() -> void:
	#text = SaveSystem.get_key("time")
	update_clock("time", SaveSystem.get_key("time"))
	SaveSystem.stats_changed.connect(update_clock)
