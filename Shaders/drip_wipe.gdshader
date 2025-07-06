shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0);
uniform bool uncover = false;
// We can use a noise texture to make the drip uneven and organic
uniform sampler2D noise;

void fragment() {
    float p = UV.y;
    // Add some noise to the y-coordinate to create the drip effect
    p -= texture(noise, vec2(UV.x, 0.0)).r * 0.2;
    
    if (uncover) {
        p = 1.0 - p;
    }
    
    float alpha = smoothstep(p - 0.1, p, progress * 1.2);
    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}