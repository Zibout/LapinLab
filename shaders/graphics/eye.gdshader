shader_type spatial;

uniform sampler2D iris_color_texture;
uniform float iris_size : hint_range(0, 1) = 0.17;
uniform float pupil_dilation : hint_range(0, 1) = 0.4;

void vertex() {
	
}

vec3 iris_color(vec2 params){
	vec3 base_color = texture(iris_color_texture, vec2(params.y, 0.0)).rgb;
	return vec3(base_color);
}

void fragment() {
	vec2 eye_coords = (UV * 2.0 - 1.0)*vec2(1.0, 0.5);
	float d = length(eye_coords);
	
	d = d / iris_size;
	
	vec2 normalized_coords = normalize(eye_coords);
	float angle = (atan(normalized_coords.y, normalized_coords.x)+PI)/(2.0*PI);
	vec2 iris_params = vec2(angle, (d-pupil_dilation)/(1.0-pupil_dilation));
	
	ALBEDO = vec3(1.0);
	ROUGHNESS = 0.0;
	
	
	if(d <= 1.0){
		ALBEDO = iris_color(iris_params);
	}
	
	d = d / pupil_dilation;
	if(d <= 1.0){
		ALBEDO = vec3(0.0);
	}
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
