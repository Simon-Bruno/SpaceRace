shader_type spatial;

uniform vec4 color : source_color;
uniform int OCTAVES = 4;
uniform bool enable_pixelation = true;
uniform int pixelation_amount = 150;
uniform sampler2D fog_mask;  // Texture mask for fog control
uniform vec2 fog_direction = vec2(1.0, 1.0); // Use -1 and 1 values to change direction. Increase the speed in that direction with values higher/lower than 1
uniform bool scroll_noise_tex = false; 
uniform vec2 noise_scroll_direction = vec2(1.0, 0.0);  // Direction to scroll the noise texture

float rand(vec2 coord){
    return fract(sin(dot(coord, vec2(56, 78)) * 1000.0) * 1000.0);
}

float noise(vec2 coord){
    vec2 i = floor(coord);
    vec2 f = fract(coord);

    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));

    vec2 cubic = f * f * (3.0 - 2.0 * f);

    return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float fbm(vec2 coord){
    float value = 0.0;
    float scale = 0.5;

    for(int i = 0; i < OCTAVES; i++){
        value += noise(coord) * scale;
        coord *= 2.0;
        scale *= 0.5;
    }
    return value;
}

void fragment() {
    vec2 grid_uv = UV;
    if (enable_pixelation) {
        grid_uv = round(UV * float(pixelation_amount)) / float(pixelation_amount);
    }
    
    // Compute noise based on pixelated or non-pixelated coordinates
    vec2 coord = grid_uv * 20.0;
	float height = coord.y; 
	
    // Scroll the noise texture if enabled
    if (scroll_noise_tex) {
        coord += noise_scroll_direction * TIME;
    }

    vec2 motion = vec2(fbm(coord + fog_direction * TIME));

    float final = fbm(coord + motion);
    
    // Get the fog density from the texture mask
    float mask_value = texture(fog_mask, UV).r;  // Assuming the mask is grayscale
    
    // Modulate the fog density by the mask value
    final *= mask_value;

    // Use the alpha value of the color to control the overall fog opacity
    ALBEDO = vec3(color.rgb);
	ALPHA = final * color.a * 10.0 * ((30.0 - height) / 30.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
