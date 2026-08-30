shader_type canvas_item;

uniform int shape_type = 0;
uniform vec4 shape_color : source_color = vec4(1.0, 1.0, 1.0, 0.5);
uniform float size : hint_range(0.0, 1.0) = 0.5;
uniform float smoothness : hint_range(0.0, 0.1) = 0.005;

void fragment() {
	vec2 center = vec2(0.5);
	vec2 position = UV - center;
	float alpha = 1.0;
	
	if (shape_type == 0) { // Circle
		float dist = length(position);
		alpha = 1.0 - smoothstep(size - smoothness, size, dist);
	}
	else if (shape_type == 1) { // Square
		float dist = max(abs(position.x), abs(position.y));
		alpha = 1.0 - smoothstep(size - smoothness, size, dist);
	}
	
	COLOR = vec4(shape_color.rgb, shape_color.a * alpha);
}