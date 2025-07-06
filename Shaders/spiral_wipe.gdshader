shader_type canvas_item;
uniform float progress : hint_range(0.0, 1.0);
uniform bool uncover = false;

void fragment() {
    vec2 p = UV - 0.5;
    float r = length(p);
    float a = atan(p.y, p.x);
    float spiral = (a / (2.0 * 3.14159)) + r * 5.0;
    float p_adjusted = uncover ? 1.0 - spiral : spiral;
    float alpha = smoothstep(p_adjusted - 0.1, p_adjusted, progress * 5.0);
    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}