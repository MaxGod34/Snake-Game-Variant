shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = UV;
    float n = 0.0;
    for (float i = 0.0; i < 8.0; i++) {
        uv.y += sin(uv.x * (i * 2.5) + TIME * 0.2) * 0.02;
        n += texture(SCREEN_TEXTURE, uv).g;
    }
    COLOR = vec4(0.0, n * 0.5, 0.0, 1.0) + vec4(0.0, 0.2, 0.0, 1.0);
}