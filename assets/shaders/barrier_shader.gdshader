shader_type spatial;
render_mode unshaded, shadows_disabled, world_vertex_coords;
#include "funcs.gdshaderinc"
uniform vec3 color: source_color;
uniform float lines1:hint_range(0.0, 200.0, 1.0) = 2.0;
uniform float lines2:hint_range(0.0, 100.0, 1.0) = 2.0;
uniform float _emission:hint_range(0.0,10.0)=1;
uniform float _fresnel:hint_range(0.0,10.0)=1;

void vertex(){
	// Remove the distortion to stop jiggling
	// float distortion = sin(TIME*10.0 + VERTEX.y*30.0);
	// VERTEX.x += distortion;
}

void fragment(){
	float n = random2_1(SCREEN_UV);
	float f = fresnel(_fresnel, NORMAL, VIEW);
	
	vec2 igrid = floor(SCREEN_UV * lines1);
	float l1 = mod(igrid.y, 2.0);
	l1 = mix(0.4,1.0,l1);
	
	vec2 uv2 = SCREEN_UV;
	uv2.y -= TIME * 0.06;
	vec2 igrid2 = floor(uv2*lines2);
	float l2 = random(igrid2.y);
	l2 = step(0.2, l2);
	l2 = mix(0.2, 1.0, l2);
	
	//ALBEDO = vec3(l2);
	float m = f*n*l1*l2;
	ALPHA = m;
	ALBEDO = color * _emission;
}
