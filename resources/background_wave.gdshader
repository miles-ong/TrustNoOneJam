shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.3, 0.6, 1.0, 1.0);
uniform float darken_amount : hint_range(0.0, 1.0) = 0.4;

uniform float wave_level : hint_range(0.0, 1.0) = 0.5; // tween this to raise/lower the wave
uniform float wave_height : hint_range(0.0, 0.5) = 0.05;
uniform float wave_frequency : hint_range(0.0, 20.0) = 6.0;
uniform float wave_speed : hint_range(0.0, 5.0) = 1.0;

void fragment() {
	vec3 bottom_color = top_color.rgb * (1.0 - darken_amount);

	float wave = sin(UV.x * wave_frequency + TIME * wave_speed) * wave_height;
	float cutoff = wave_level + wave;

	float region = step(cutoff, UV.y); // 0 above, 1 below
	vec3 final_color = mix(top_color.rgb, bottom_color, region);

	COLOR = vec4(final_color, top_color.a);
}