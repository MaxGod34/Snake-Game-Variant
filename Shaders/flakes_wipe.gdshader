shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0);
uniform bool uncover = false;
uniform sampler2D noise;

void fragment() {
    float p = texture(noise, UV).r; // Get a random value for each pixel
    
    float p_adjusted = p;
    if (uncover) {
        p_adjusted = 1.0 - p;
    }
    
    // Use step() to make the pixels appear/disappear instantly, like flakes
    float alpha = step(p_adjusted, progress);
    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}