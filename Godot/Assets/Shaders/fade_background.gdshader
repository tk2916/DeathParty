shader_type canvas_item;

uniform float tint_strength : hint_range(0.0, 1.0) = 0.5;
uniform vec4 tint_color : source_color = vec4(0.0, 0.0, 1.0, 1.0);
uniform vec2 exclusion_center;
uniform vec2 exclusion_size;
uniform float exclusion_rotation;
uniform vec2 screen_size;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

vec2 rotate_point(vec2 point, float theta) {
	// x' = x*cos(theta) - y*sin(theta)
	// y' = x*sin(theta) + y*cos(theta)
	theta = theta*0.0174533;
	float cos_angle = cos(theta);
	float sin_angle = sin(theta);
	float x_prime = point.x*cos_angle - point.y*sin_angle;
	float y_prime = point.x*sin_angle + point.y*cos_angle;
	return vec2(x_prime, y_prime);
}

void fragment() {
	//make rotated exclusion rectangle
	vec2 screen_pos = SCREEN_UV * screen_size;
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	//rotate around rectangle origin (relative)
	//we are rotating the screen's pixels to match the rect rotation
	vec2 relative_pos = screen_pos-exclusion_center;
	vec2 rotated_pos = rotate_point(relative_pos, exclusion_rotation);
	//if the rotated version of the coordinates falls within the zone, exclude that pixel
	if (abs(rotated_pos.y) <= exclusion_size.y && abs(rotated_pos.x) <= exclusion_size.x) {
		COLOR = screen_color;
	} else {
		COLOR = mix(screen_color, tint_color, tint_strength);
	}
}
