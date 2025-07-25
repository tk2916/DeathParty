extends SpotLight3D


var i := randi_range(1, 3)


func _ready() -> void:
	var timer: Timer = $Timer
	timer.timeout.connect(_on_timer_timeout)


func _on_timer_timeout() -> void:
	match i:
		1:
			light_color = Color.DEEP_PINK
			i += 1
		2:
			light_color = Color.DARK_ORANGE
			i += 1
		3:
			light_color = Color.PALE_GREEN
			i = 1
