shader_type spatial;

uniform sampler2D albedo_texture: source_color;

void fragment() {
    vec4 texture_color = texture(albedo_texture, UV);
	vec4 color;
    
    // Check if we're looking at the front or back face
    if (dot(NORMAL, VIEW) > 0.0) {
        ALBEDO = texture_color.rgb;
        ALPHA = texture_color.a;
    } else {
		ALBEDO = texture_color.rgb;
        ALPHA = texture_color.a * 0.5;
	}
}
