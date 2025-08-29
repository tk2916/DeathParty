shader_type canvas_item;

uniform float multiplier : hint_range(0.0, 2.0, 0.05) = .6;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 input_color = texture(TEXTURE, UV); //uv is like coordinates of texture
	vec3 brightened_color = input_color.rgb * multiplier;
	COLOR = vec4(clamp(brightened_color, vec3(0.0), vec3(1.0)), input_color.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
