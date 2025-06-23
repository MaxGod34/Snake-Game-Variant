// This shader will smoothly change the line's color
shader_type canvas_item;

uniform float trend = 0.0;

void fragment() {
    vec3 down = vec3(1.0, 0.2, 0.2); // red-ish
    vec3 up = vec3(0.2, 1.0, 0.2);   // green-ish

    // Map -1 to 1 into 0 to 1
    float t = (trend + 1.0) * 0.5;

    vec3 final_color = mix(down, up, t);
    COLOR = vec4(final_color, 1.0);
}
