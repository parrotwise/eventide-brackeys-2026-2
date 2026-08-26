shader_type canvas_item;


uniform sampler2D shadow_gradient;
uniform float shadow_intensity;
uniform sampler2D status_sloshed_overlay;
uniform float status_sloshed_intensity;

instance uniform bool status_overlay_sloshed_enabled;


vec3 multiply(vec3 base, vec3 blend) {
	return base * blend;
}

vec3 screen(vec3 base, vec3 blend) {
	return 1.0 - (1.0 - base) * (1.0 - blend);
}

vec3 overlay(vec3 base, vec3 blend){
	vec3 limit = step(0.5, base);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	color.rgb = mix(
		color.rgb,
		multiply(color.rgb, texture(shadow_gradient, UV).rgb),
		shadow_intensity
	);
	
	if (status_overlay_sloshed_enabled) {
		color.rgb = mix(
			color.rgb,
			overlay(color.rgb, texture(status_sloshed_overlay, UV).rgb),
			status_sloshed_intensity
		);
	}
	
	COLOR = color;
}
