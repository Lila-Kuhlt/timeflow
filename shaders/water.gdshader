shader_type canvas_item;

/** The frequency of the standing waves, i.e. the number of waves per second. */
uniform float frequency = 0.5;
/** The amplitude of the standing waves. */
uniform float amplitude = 0.1;
/** The spatial frequency of the standing waves, i.e. the number of waves per tile. */
uniform int spatial_frequency = 1;
/** The size of a single tile in pixels. */
uniform ivec2 tile_size_px = ivec2(16, 16);
/** The scale of the noise. */
uniform float noise_scale = 0.5;
/** The noise texture. The z coordinate is used as time. */
uniform sampler3D noise_texture : repeat_enable;
/** Use a gray background instead of the texture, to better visualize the shader. */
uniform bool debug = false;

const float two_pi = 2.0 * PI;

void fragment() {
	// convert tile set coordinates to tile coordinates
	vec2 tile_size = TEXTURE_PIXEL_SIZE * vec2(tile_size_px);
	vec2 uv = mod(UV, tile_size) / tile_size;

	// standing wave
	float wave = sin(float(spatial_frequency) * two_pi * uv.x)
		* sin(float(spatial_frequency) * two_pi * uv.y)
		* cos(TIME * two_pi * frequency) * amplitude + 1.0;
	float noise = (texture(noise_texture, vec3(uv, TIME)).r * 2.0 - 1.0) * noise_scale;
	wave += noise;
	if (debug) {
		// make background gray for better visualization
		COLOR = vec4(0.5, 0.5, 0.5, 1.0);
	}
	COLOR *= vec4(wave, wave, wave, 1.0);
}
