shader_type spatial;
render_mode unshaded;
// references:
// https://stackoverflow.com/a/74645011

uniform float height;
uniform vec3 spheres[128];
uniform uint sphere_count;

uniform sampler2D tex1 : filter_nearest_mipmap;
uniform sampler2D tex2 : filter_nearest_mipmap;

const float inf = 1.0 / 0.0;

void fragment()
{
    vec3 pixel_world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	//float min_dist = inf;
	//float r = 0.0;
	//for(uint i = 0u; i < sphere_count; i++) {
		//vec3 v = spheres[i];
		//float dist = distance(vec3(v.x, height, v.y), pixel_world_pos);
		//if(dist < min_dist) {
			//min_dist = dist;
			//r = v.z;
		//}
	//}
	float min_threshold = inf;
	for(uint i = 0u; i < sphere_count; i++) {
		vec3 v = spheres[i];
		float dist = distance(vec3(v.x, height, v.y), pixel_world_pos);
		float threshold = step(v.z, dist);
		if(threshold < min_threshold) {
			min_threshold = threshold;
		}
	}
    ALBEDO.rgb = mix(texture(tex1, UV).rgb, texture(tex2, UV).rgb, min_threshold);
    //EMISSION = vec3(step(dist, edge + radius) * step(radius, dist));
	//EMISSION = ALBEDO;
}