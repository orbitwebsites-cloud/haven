shader_type canvas_item;

// makes the whole screen look hand drawn: wobbly lines, pen outlines, marker streaks, lined paper.
// swap ink_color / rule_color to change the vibe. paper_color has to match the Paper rect in background.tscn
// and the clear colour in project settings, change all three together (dark paper + white ink = chalkboard)

uniform sampler2D screen_tex : hint_screen_texture, filter_linear, repeat_disable;
uniform sampler2D noise_tex : repeat_enable, filter_linear;
uniform vec4 paper_color : source_color = vec4(0.96, 0.93, 0.84, 1.0);
uniform vec4 ink_color : source_color = vec4(0.13, 0.13, 0.2, 1.0);
uniform vec4 rule_color : source_color = vec4(0.5, 0.68, 0.9, 1.0);
uniform vec4 margin_color : source_color = vec4(0.9, 0.45, 0.45, 1.0);
uniform float wobble = 2.2;
uniform float boil_fps = 6.0;
uniform float outline = 0.9;
uniform float rule_gap = 34.0;
uniform float rule_strength = 0.45;

void fragment() {
	// work in "design pixels" (1152 x 648, whichever side runs out first) so it looks the same at any window size
	vec2 px = SCREEN_PIXEL_SIZE;
	float zoom = min(1.0 / (px.x * 1152.0), 1.0 / (px.y * 648.0));
	vec2 design = SCREEN_UV / (px * zoom);

	// the wobble jumps a few times a second, like every frame got redrawn by hand
	float tick = floor(TIME * boil_fps);
	vec2 nuv = design / 300.0 + vec2(tick * 0.37, tick * 0.71);
	vec2 jitter = vec2(texture(noise_tex, nuv).r, texture(noise_tex, nuv + vec2(0.43, 0.17)).r) - 0.5;
	vec2 uv = SCREEN_UV + jitter * 2.0 * wobble * px * zoom;

	vec3 col = texture(screen_tex, uv).rgb;
	float on_paper = 1.0 - smoothstep(0.03, 0.08, distance(col, paper_color.rgb));

	// pen outline wherever the colour changes sharply
	vec2 o = px * zoom * 1.3;
	vec3 l = texture(screen_tex, uv - vec2(o.x, 0.0)).rgb;
	vec3 r = texture(screen_tex, uv + vec2(o.x, 0.0)).rgb;
	vec3 u = texture(screen_tex, uv - vec2(0.0, o.y)).rgb;
	vec3 d = texture(screen_tex, uv + vec2(0.0, o.y)).rgb;
	float edge = smoothstep(0.1, 0.32, max(distance(l, r), distance(u, d)));

	// printed lines of the notebook page, only where the paper shows through
	float line = 1.0 - smoothstep(0.6, 1.4, abs(mod(design.y, rule_gap) - rule_gap * 0.5));
	col = mix(col, rule_color.rgb, line * on_paper * rule_strength);
	float margin = 1.0 - smoothstep(0.8, 1.6, abs(design.x - 70.0));
	col = mix(col, margin_color.rgb, margin * on_paper * rule_strength);

	// marker streaks on anything coloured in, a bit of grain on everything
	float streak = texture(noise_tex, vec2(design.x / 420.0, design.y / 14.0)).r;
	col = mix(col * (0.84 + 0.24 * streak), col, on_paper);
	float grain = texture(noise_tex, design / 40.0).r;
	col *= 0.95 + 0.07 * grain;

	// press harder in some spots than others, like a real pen
	float pressure = 0.65 + 0.35 * texture(noise_tex, design / 90.0 + vec2(tick * 0.13)).r;
	col = mix(col, ink_color.rgb, edge * outline * pressure);

	COLOR = vec4(col, 1.0);
}
