// Ghost / Yurei Material Shader
// Pale, translucent, with edge glow and vertical scroll distortion.
// Keep render cost minimal — no heavy sampling.

shader_type spatial;
render_mode blend_add, depth_draw_never, cull_disabled, unshaded;

uniform vec4  ghost_color    : source_color = vec4(0.75, 0.82, 1.0, 0.55);
uniform float edge_glow      : hint_range(0.0, 3.0) = 1.4;
uniform float distort_speed  : hint_range(0.0, 2.0) = 0.6;
uniform float distort_amount : hint_range(0.0, 0.05) = 0.018;
uniform float flicker_speed  : hint_range(0.0, 10.0) = 3.5;

void fragment() {
    // Fresnel edge glow
    float fresnel = pow(1.0 - abs(dot(NORMAL, VIEW)), edge_glow);

    // Vertical distortion using time
    float distort = sin(UV.y * 12.0 + TIME * distort_speed) * distort_amount;
    vec2 uv_d = UV + vec2(distort, 0.0);

    // Subtle flicker
    float flicker = 0.85 + 0.15 * sin(TIME * flicker_speed + UV.y * 4.0);

    float alpha = (ghost_color.a + fresnel * 0.35) * flicker;
    alpha = clamp(alpha, 0.0, 0.9);

    ALBEDO = ghost_color.rgb * (1.0 + fresnel * 0.5);
    ALPHA  = alpha;
    EMISSION = ghost_color.rgb * fresnel * 0.6;
}
