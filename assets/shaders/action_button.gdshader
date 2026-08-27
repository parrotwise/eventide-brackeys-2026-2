shader_type canvas_item;


uniform sampler2D layer_bg;
uniform sampler2D layer_icon;
uniform sampler2D layer_glow;
uniform sampler2D layer_frame;


vec4 composite(vec4 color1, vec4 color2) {
	vec4 color = color1;
	color.rgb = color1.rgb * (1.0 - color2.a) + color2.rgb * color2.a;
	color.a = 1.0 - ((1.0 - color1.a) * (1.0 - color2.a));
	return color;
}


void fragment() {
	vec4 color = vec4(0);
	
	color = composite(color, texture(layer_bg, UV));
	color = composite(color, texture(layer_icon, UV));
	color = composite(color, texture(layer_glow, UV));
	color = composite(color, texture(layer_frame, UV));
	
	COLOR = color;
}
