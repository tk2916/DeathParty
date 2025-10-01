shader_type canvas_item;

uniform float tint_strength : hint_range(0.0, 1.0) = 0.5;
uniform vec4 tint_color : source_color = vec4(0.0, 0.0, 1.0, 1.0);
uniform vec2 exclusion_corner;
uniform vec2 exclusion_size;
uniform float exclusion_rotation;
uniform vec2 aspect_ratio;
uniform sampler2D screen_texture : hint_screen_texture;

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
	vec2 screen_pos = UV * aspect_ratio;
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	
	//make the corner the origin (to then rotate)
	vec2 relative_pos = screen_pos-exclusion_corner;
	
	vec2 rotated_pos = rotate_point(relative_pos, -exclusion_rotation);
	if (
		rotated_pos.y >= 0.0
		&& rotated_pos.y <= exclusion_size.y
		&& rotated_pos.x >= 0.0
		&& rotated_pos.x <= exclusion_size.x
	) {
		COLOR = screen_color;
	} else {
		
		vec3 tinted_rgb = mix(screen_color.rgb, tint_color.rgb, tint_strength);
        float final_alpha = screen_color.a; //store alpha separately
		COLOR = vec4(tinted_rgb, final_alpha);
	}
}
