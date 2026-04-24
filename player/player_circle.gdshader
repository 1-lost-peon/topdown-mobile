shader_type spatial;
render_mode unshaded, blend_mix, depth_prepass_alpha, cull_disabled;

uniform vec4 outline_color : source_color = vec4(0.1, 1.0, 0.15, 1.0);
uniform vec4 center_color : source_color = vec4(1.0, 1.0, 1.0, 0.2);
uniform float radius = 0.42;
uniform float outline_width = 0.06;
uniform float glow_width = 0.08;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);

	float circle = smoothstep(radius, radius - 0.01, dist);
	float outline = smoothstep(radius, radius - 0.01, dist)
		- smoothstep(radius - outline_width, radius - outline_width - 0.01, dist);

	float glow = smoothstep(radius + glow_width, radius, dist) * 0.35;

	vec4 col = center_color;
	col = mix(col, outline_color, outline);
	col.rgb += outline_color.rgb * glow;

	col.a *= circle;
	col.a = max(col.a, outline * outline_color.a);
	col.a += glow * outline_color.a * outline;

	ALBEDO = col.rgb;
	ALPHA = col.a;
}