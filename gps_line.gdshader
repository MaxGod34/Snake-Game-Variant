shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.0, 1.0, 0.0, 1.0); // Default to Green
uniform float intensity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    // We mix between a dull gray and the vibrant base color
    // based on the intensity (how high the GPS is).
    COLOR = mix(vec4(0.5, 0.5, 0.5, 1.0), base_color, intensity);
}
