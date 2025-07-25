extends SpotLight3D


# initialise i (the variable that controls where we are in the lighting pattern loop)
# at a random value so the lights dont all start as the same colour
var i := randi_range(1, 3)

# set the rotation speed in degrees
var rotation_speed_degrees := 0.6
# convert the speed to radians for the physics calculation later
var rotation_speed_rad := deg_to_rad(rotation_speed_degrees)

# set the weight/speed of the transition between colors
var hue_shift_lerp_weight:= 0.05
# initialise the target colour var (empty
var target_color: Color

# initialise vars for moving the circular filters up and down
var filter: MeshInstance3D
var time_elapsed := 0.0


func _ready() -> void:
	# get a reference to the timer and connect it to the function below
	var timer: Timer = $Timer
	timer.timeout.connect(_on_timer_timeout)

	# get a reference to the circular filter below the spotlight
	# (if there is one and its node is a child of the light and named "Filter")
	filter = $Filter


func _physics_process(delta: float) -> void:
	# rotate the light and its children (incl. the filters or the disco ball)
	rotate_object_local(Vector3.FORWARD, rotation_speed_rad)
	
	# smoothly change the light color
	light_color = lerp(light_color, target_color, hue_shift_lerp_weight)

	# smoothly move the filter up and down to change the spotlight size
	time_elapsed += delta
	var offset := sin(time_elapsed) * 0.015
	if filter != null:
		filter.translate_object_local(Vector3(0, offset, 0))


# when the timer times out, cycle to the next colour
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
