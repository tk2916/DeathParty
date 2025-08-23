shader_type spatial;
render_mode cull_front, unshaded;

uniform vec3 color : source_color = vec3(255,255,255);
uniform float thickness : hint_range(0.0, 2.0, 0.01) = 0.7;
uniform float alpha : hint_range(0.0, 1.0, 0.01) = 1.0;

void vertex() {
	VERTEX += thickness * NORMAL;
}

void fragment() {
	ALBEDO = color;
	ALPHA = alpha;
}