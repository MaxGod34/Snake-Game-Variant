shader_type canvas_item;
void fragment() {
    float scanline = sin((UV.y + TIME * 0.1) * 200.0) * 0.05;
    COLOR = vec4(vec3(0.05, 0.08, 0.15) + scanline, 1.0);
}
