shader_type spatial;

uniform sampler2D albedo_texture : source_color;
uniform float fade_alpha : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 color = texture(albedo_texture, UV);
    ALPHA = fade_alpha; //vec4(color.rgb, color.a * fade_alpha);
	ALBEDO = color.rgb;
}