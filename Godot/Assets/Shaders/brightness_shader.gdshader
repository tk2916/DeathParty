shader_type spatial;

uniform sampler2D albedo_texture : source_color;
uniform float multiplier : hint_range(0.0, 2.0, 0.05) = .6;

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 input_color = texture(albedo_texture, UV); //uv is like coordinates of texture
	vec3 brightened_color = input_color.rgb * multiplier;
	ALBEDO = clamp(brightened_color, 0, 1); //prevents overflow
	ALPHA = input_color.a;
}
