shader_type canvas_item;

uniform sampler2D noise : hint_normal;
uniform float strength : hint_range(0.0, 0.1) = 0.02;
uniform float speed = 0.5;

void fragment() {
    // Scroll noise over time
    vec2 offset = texture(noise, UV + TIME * speed).rg;
    // Shift UVs for distortion
    vec2 distorted_uv = UV + (offset - 0.5) * strength;
    // Sample texture or screen
    COLOR = texture(TEXTURE, distorted_uv);
}