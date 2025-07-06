shader_type canvas_item;
uniform float progress : hint_range(0.0, 1.0);
uniform bool uncover = false;

void fragment() {
    float p = UV.x + UV.y;
    if (uncover) { p = 2.0 - p; }
    float alpha = smoothstep(p - 0.1, p, progress * 2.2);
    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
