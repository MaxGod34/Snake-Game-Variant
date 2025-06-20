shader_type canvas_item;

// A uniform is a variable we can change from our GDScript code if we want
uniform float offset_strength : hint_range(0.0, 0.1) = 0.005;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


void fragment() {
    // Get the pixel color from the screen texture at different, slightly offset points
    vec4 red_channel = texture(SCREEN_TEXTURE, SCREEN_UV - vec2(offset_strength, 0.0));
    vec4 green_channel = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec4 blue_channel = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(offset_strength, 0.0));

    // Combine the red from the first texture, the green from the second,
    // and the blue from the third to create the final color.
    COLOR = vec4(red_channel.r, green_channel.g, blue_channel.b, green_channel.a);
}