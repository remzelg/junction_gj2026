shader_type canvas_item;

uniform vec4 ping_color : source_color = vec4(0.0, 1.0, 0.8, 1.0);
uniform float speed : hint_range(0.1, 5.0) = 1.5;
uniform float frequency : hint_range(1.0, 20.0) = 5.0;
uniform float spawn_time = 0.0;
uniform float phase_offset = 0.0;

void fragment() {
    // Center the UV coordinates from 0.5 to -0.5
    vec2 uv = UV - 0.5;
    float dist = length(uv) * 2.0; // Distance from center (0.0 to 1.0+)

    // Create expanding wave using time since spawn and fract/modulus
    float phase = (TIME - spawn_time) * speed + phase_offset;
    float wave = sin(dist * frequency - phase);
    
    // Mask out the center/outer bounds and make it fade with distance
    float mask = smoothstep(1.0, 0.0, dist);
    float ring = pow(max(0.0, wave), 4.0) * mask;
    
    // Output final color with alpha transparency
    COLOR = ping_color * ring;
}