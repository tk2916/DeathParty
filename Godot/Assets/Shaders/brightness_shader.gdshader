shader_type spatial;

uniform bool ignore_lighting = true;
uniform sampler2D albedo_texture : source_color;
uniform float brightness : hint_range(0.0, 2.0, 0.05) = .6;
uniform float contrast : hint_range(0.0, 2.0, 0.05) = 1.0;

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 input_color = texture(albedo_texture, UV); //uv is like coordinates of texture
	vec3 brightened_color = input_color.rgb * brightness;
	brightened_color = clamp(brightened_color, 0, 1); //prevents overflow
	brightened_color = (brightened_color - 0.5) * contrast + 0.5;
	if (ignore_lighting) {
        // emission ignores lighting
        EMISSION = brightened_color;
        ALBEDO = vec3(0.0);
    } else {
        // considers lighting
        ALBEDO = brightened_color;
    }
	ALPHA = input_color.a;
}
