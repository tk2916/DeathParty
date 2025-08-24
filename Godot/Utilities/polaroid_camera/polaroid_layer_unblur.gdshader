shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest_mipmap;
uniform float lod = 0;

void fragment() {
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, lod);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
