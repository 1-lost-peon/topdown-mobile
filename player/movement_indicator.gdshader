shader_type spatial;
render_mode unshaded, blend_mix, depth_prepass_alpha, cull_disabled;

uniform vec4 circle_color : source_color = vec4(0.35, 0.95, 0.55, 1.0);
uniform float radius = 0.32;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);

	float alpha = smoothstep(radius, radius - 0.015, dist);

	ALBEDO = circle_color.rgb;
	ALPHA = circle_color.a * alpha;
}