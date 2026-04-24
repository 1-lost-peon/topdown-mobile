shader_type spatial;
render_mode unshaded, blend_mix, depth_prepass_alpha, cull_disabled;

uniform vec4 rect_color : source_color = vec4(0.65, 0.68, 0.70, 0.35);

uniform float max_width = 0.0;
uniform float width = 0.5;
uniform float height = 0.04;
uniform float radius = 0.02;
uniform float edge_softness = 0.01;

float rounded_box(vec2 p, vec2 half_size, float r) {
	vec2 q = abs(p) - half_size + vec2(r);
	return length(max(q, 0.0)) - r;
}

void fragment() {
	vec2 p = UV - vec2(0.5);

	// Right side anchored, shrinks inward toward center/left
	p.x -= (max_width - width) * 0.5;

	float d = rounded_box(
		p,
		vec2(width * 0.5, height * 0.5),
		radius
	);

	float alpha = smoothstep(edge_softness, -edge_softness, d);

	ALBEDO = rect_color.rgb;
	ALPHA = rect_color.a * alpha;
}