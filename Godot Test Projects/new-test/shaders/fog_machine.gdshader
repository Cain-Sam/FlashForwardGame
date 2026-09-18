shader_type fog;

uniform sampler2D noise_texture:repeat_enable;
uniform float noise_scale = 1.0;
uniform float flatness = 1.0;
uniform float density = 1.0; 
uniform sampler2D gradiant; 

void fog() {
	vec2 movement = vec2(0.07, 0.0)*TIME;
	float detail_noise = texture(noise_texture, WORLD_POSITION.xz*noise_scale + movement).r; 
	detail_noise *= 0.2;
	float noise = texture(noise_texture, WORLD_POSITION.xz*noise_scale + movement + detail_noise).r;
	DENSITY = mix(1.0, noise, UVW.y*flatness);
	DENSITY *= step(0.0, -SDF)*density;
	vec3 color = texture(gradiant, vec2(DENSITY, 0.5)).rgb;
	ALBEDO = vec3(color);
}
