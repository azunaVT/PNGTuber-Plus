shader_type canvas_item;

uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform int blend_mode : hint_range(0, 11) = 0;

// Blend mode constants:
// 0: Normal
// 1: Multiply
// 2: Screen
// 3: Overlay
// 4: Soft Light
// 5: Hard Light
// 6: Color Dodge
// 7: Color Burn
// 8: Darken
// 9: Lighten
// 10: Add (Linear Dodge)
// 11: Subtract

vec3 multiply_blend(vec3 base, vec3 overlay) {
	return base * overlay;
}

vec3 screen_blend(vec3 base, vec3 overlay) {
	return 1.0 - (1.0 - base) * (1.0 - overlay);
}

vec3 overlay_blend(vec3 base, vec3 overlay) {
	vec3 result;
	result.r = base.r < 0.5 ? 2.0 * base.r * overlay.r : 1.0 - 2.0 * (1.0 - base.r) * (1.0 - overlay.r);
	result.g = base.g < 0.5 ? 2.0 * base.g * overlay.g : 1.0 - 2.0 * (1.0 - base.g) * (1.0 - overlay.g);
	result.b = base.b < 0.5 ? 2.0 * base.b * overlay.b : 1.0 - 2.0 * (1.0 - base.b) * (1.0 - overlay.b);
	return result;
}

vec3 soft_light_blend(vec3 base, vec3 overlay) {
	vec3 result;
	result.r = overlay.r < 0.5 ? 2.0 * base.r * overlay.r + base.r * base.r * (1.0 - 2.0 * overlay.r) : 
		sqrt(base.r) * (2.0 * overlay.r - 1.0) + 2.0 * base.r * (1.0 - overlay.r);
	result.g = overlay.g < 0.5 ? 2.0 * base.g * overlay.g + base.g * base.g * (1.0 - 2.0 * overlay.g) : 
		sqrt(base.g) * (2.0 * overlay.g - 1.0) + 2.0 * base.g * (1.0 - overlay.g);
	result.b = overlay.b < 0.5 ? 2.0 * base.b * overlay.b + base.b * base.b * (1.0 - 2.0 * overlay.b) : 
		sqrt(base.b) * (2.0 * overlay.b - 1.0) + 2.0 * base.b * (1.0 - overlay.b);
	return result;
}

vec3 hard_light_blend(vec3 base, vec3 overlay) {
	vec3 result;
	result.r = overlay.r < 0.5 ? 2.0 * base.r * overlay.r : 1.0 - 2.0 * (1.0 - base.r) * (1.0 - overlay.r);
	result.g = overlay.g < 0.5 ? 2.0 * base.g * overlay.g : 1.0 - 2.0 * (1.0 - base.g) * (1.0 - overlay.g);
	result.b = overlay.b < 0.5 ? 2.0 * base.b * overlay.b : 1.0 - 2.0 * (1.0 - base.b) * (1.0 - overlay.b);
	return result;
}

vec3 color_dodge_blend(vec3 base, vec3 overlay) {
	vec3 result;
	result.r = overlay.r >= 1.0 ? 1.0 : min(1.0, base.r / (1.0 - overlay.r));
	result.g = overlay.g >= 1.0 ? 1.0 : min(1.0, base.g / (1.0 - overlay.g));
	result.b = overlay.b >= 1.0 ? 1.0 : min(1.0, base.b / (1.0 - overlay.b));
	return result;
}

vec3 color_burn_blend(vec3 base, vec3 overlay) {
	vec3 result;
	result.r = overlay.r <= 0.0 ? 0.0 : max(0.0, 1.0 - (1.0 - base.r) / overlay.r);
	result.g = overlay.g <= 0.0 ? 0.0 : max(0.0, 1.0 - (1.0 - base.g) / overlay.g);
	result.b = overlay.b <= 0.0 ? 0.0 : max(0.0, 1.0 - (1.0 - base.b) / overlay.b);
	return result;
}

vec3 darken_blend(vec3 base, vec3 overlay) {
	return min(base, overlay);
}

vec3 lighten_blend(vec3 base, vec3 overlay) {
	return max(base, overlay);
}

vec3 add_blend(vec3 base, vec3 overlay) {
	return min(vec3(1.0), base + overlay);
}

vec3 subtract_blend(vec3 base, vec3 overlay) {
	return max(vec3(0.0), base - overlay);
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	// Apply blend mode (only to RGB, preserve alpha channel behavior)
	vec3 final_color;
	
	if (blend_mode == 0) { // Normal
		final_color = tex_color.rgb;
	} else if (blend_mode == 1) { // Multiply
		final_color = multiply_blend(vec3(1.0), tex_color.rgb);
	} else if (blend_mode == 2) { // Screen
		final_color = screen_blend(vec3(0.0), tex_color.rgb);
	} else if (blend_mode == 3) { // Overlay
		final_color = overlay_blend(vec3(0.5), tex_color.rgb);
	} else if (blend_mode == 4) { // Soft Light
		final_color = soft_light_blend(vec3(0.5), tex_color.rgb);
	} else if (blend_mode == 5) { // Hard Light
		final_color = hard_light_blend(vec3(0.5), tex_color.rgb);
	} else if (blend_mode == 6) { // Color Dodge
		final_color = color_dodge_blend(vec3(0.0), tex_color.rgb);
	} else if (blend_mode == 7) { // Color Burn
		final_color = color_burn_blend(vec3(1.0), tex_color.rgb);
	} else if (blend_mode == 8) { // Darken
		final_color = darken_blend(vec3(1.0), tex_color.rgb);
	} else if (blend_mode == 9) { // Lighten
		final_color = lighten_blend(vec3(0.0), tex_color.rgb);
	} else if (blend_mode == 10) { // Add (Linear Dodge)
		final_color = add_blend(vec3(0.0), tex_color.rgb);
	} else if (blend_mode == 11) { // Subtract
		final_color = subtract_blend(vec3(1.0), tex_color.rgb);
	} else {
		final_color = tex_color.rgb;
	}
	
	COLOR = vec4(final_color, tex_color.a * opacity);
}
