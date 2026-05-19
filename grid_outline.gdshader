shader_type spatial;

render_mode blend_mix, depth_draw_never, cull_disabled, unshaded;

uniform float line_thickness : hint_range(0.001, 0.5) = 0.05;

void fragment() {
	vec2 uv = UV;

	float left = uv.x;
	float right = 1.0 - uv.x;
	float top = uv.y;
	float bottom = 1.0 - uv.y;

	float edge_dist = min(min(left, right), min(top, bottom));

	if (edge_dist <= line_thickness) {
		ALBEDO = vec3(0.0, 0.0, 0.0);
		ALPHA = 0.5;
	} else {
		ALPHA = 0.0;
	}
}