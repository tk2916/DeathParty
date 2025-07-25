extends SpotLight3D


# initialise i (the variable that controls where we are in the lighting pattern loop)
# at a random value so the lights dont all start as the same colour
var i := randi_range(1, 3)

# set the rotation speed in degrees
var rotation_speed_degrees := 0.6
# convert the speed to radians for the physics calculation later
var rotation_speed_rad := deg_to_rad(rotation_speed_degrees)

# set the weight of the transition between colors
var hue_shift_lerp_weight:= 0.05
var target_color : Color


func _ready() -> void:
	var timer: Timer = $Timer
	timer.timeout.connect(_on_timer_timeout)


func _physics_process(delta: float) -> void:
	# rotate the light and its children (incl. the circles and the disco ball)
	rotate_object_local(Vector3.FORWARD, rotation_speed_rad)
	
	# smoothly change the light color
	light_color = lerp(light_color, target_color, hue_shift_lerp_weight)

func _on_timer_timeout() -> void:
	match i:
		1:
			target_color = Color.DEEP_PINK
			i += 1
		2:
			target_color = Color.DARK_ORANGE
			i += 1
		3:
			target_color = Color.PALE_GREEN
			i = 1
