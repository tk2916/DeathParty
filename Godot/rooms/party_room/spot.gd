extends SpotLight3D

var hue : float = 0.0
var speed : float = 0.5  # Adjust to make it faster or slower

func _process(delta):
	hue = (hue + speed * delta) % 1.0
	light_color = Color.from_hsv(hue, 1.0, 1.0)
