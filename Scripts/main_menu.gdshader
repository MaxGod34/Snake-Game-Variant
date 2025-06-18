shader_type canvas_item;

uniform sampler2D snake_texture : hint_albedo;
uniform vec2 tile_size = vec2(32.0, 32.0);

void fragment() {
    vec2 uv = FRAGCOORD.xy / tile_size;
    COLOR = texture(snake_texture, fract(uv));
}


//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
