shader_type canvas_item;

uniform float grid_thickness : hint_range(0.0, 2.0) = 1.0;
uniform vec4 grid_color : source_color = vec4(0.3, 0.3, 0.5, 0.5);

void fragment() {
	// --- Animated Background Color ---
	// We use sine waves with the built-in TIME variable to create a slow, shifting color gradient.
	vec2 uv_shifted = SCREEN_UV + vec2(sin(TIME * 0.2), cos(TIME * 0.1));
	vec3 bg_color = vec3(0.0, sin(uv_shifted.x * 2.0 + TIME * 0.5) * 0.1, cos(uv_shifted.y * 2.0 + TIME * 0.3) * 0.1);
	
	// --- Grid Line Logic ---
	// Calculate our position on the screen in pixels
	vec2 pos = FRAGCOORD.xy;
	// Check if the current pixel is on a vertical or horizontal line
	if (mod(pos.x, 32.0) < grid_thickness || mod(pos.y, 32.0) < grid_thickness) {
		COLOR = vec4(grid_color.rgb, 1.0); // If yes, draw the grid color
	} else {
		COLOR = vec4(bg_color, 1.0); // If no, draw the animated background color
	}
}