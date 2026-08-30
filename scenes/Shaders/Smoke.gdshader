shader_type canvas_item;

// =====================================================
// MASTER SETTINGS
// =====================================================

// Overall opacity multiplier for the entire fog effect.
// 0.0 = invisible
// 1.0 = full shader opacity
uniform float master_opacity : hint_range(0.0, 1.0, 0.01) = 0.35;


// =====================================================
// CLOUD LAYER 1
// =====================================================

uniform vec4 cloud_color_1 : source_color = vec4(0.25, 0.35, 0.85, 1.0);

// Larger value = smaller/more frequent cloud blobs
uniform float cloud_scale_1 : hint_range(0.2, 10.0, 0.01) = 2.2;

// Movement direction and speed
uniform vec2 cloud_speed_1 = vec2(0.015, 0.008);

// Controls how much of the noise becomes visible cloud
// Higher = fewer, more isolated clouds
uniform float cloud_threshold_1 : hint_range(0.0, 1.0, 0.01) = 0.48;

// Controls softness of cloud edges
uniform float cloud_softness_1 : hint_range(0.01, 0.5, 0.01) = 0.16;

// Independent opacity for this layer
uniform float cloud_opacity_1 : hint_range(0.0, 1.0, 0.01) = 0.65;


// =====================================================
// CLOUD LAYER 2
// =====================================================

uniform vec4 cloud_color_2 : source_color = vec4(0.45, 0.15, 0.65, 1.0);

uniform float cloud_scale_2 : hint_range(0.2, 10.0, 0.01) = 3.8;

uniform vec2 cloud_speed_2 = vec2(-0.008, 0.012);

uniform float cloud_threshold_2 : hint_range(0.0, 1.0, 0.01) = 0.52;

uniform float cloud_softness_2 : hint_range(0.01, 0.5, 0.01) = 0.18;

uniform float cloud_opacity_2 : hint_range(0.0, 1.0, 0.01) = 0.45;


// =====================================================
// SHAPE / DETAIL
// =====================================================

// Number of noise octaves.
// Higher values add more detail but cost more GPU time.
uniform float detail_strength : hint_range(0.0, 1.0, 0.01) = 0.45;

// Slowly warps the noise so clouds feel more organic.
uniform float distortion_strength : hint_range(0.0, 1.0, 0.01) = 0.20;

uniform float distortion_speed : hint_range(0.0, 0.2, 0.001) = 0.015;


// =====================================================
// RANDOM / PERLIN-STYLE GRADIENT NOISE
// =====================================================

vec2 hash2(vec2 p)
{
	p = vec2(
		dot(p, vec2(127.1, 311.7)),
		dot(p, vec2(269.5, 183.3))
	);

	return -1.0 + 2.0 * fract(
		sin(p) * 43758.5453123
	);
}


float gradient_noise(vec2 p)
{
	vec2 i = floor(p);
	vec2 f = fract(p);

	vec2 u =
		f * f * (3.0 - 2.0 * f);

	float n00 =
		dot(
			hash2(i + vec2(0.0, 0.0)),
			f - vec2(0.0, 0.0)
		);

	float n10 =
		dot(
			hash2(i + vec2(1.0, 0.0)),
			f - vec2(1.0, 0.0)
		);

	float n01 =
		dot(
			hash2(i + vec2(0.0, 1.0)),
			f - vec2(0.0, 1.0)
		);

	float n11 =
		dot(
			hash2(i + vec2(1.0, 1.0)),
			f - vec2(1.0, 1.0)
		);


	float nx0 =
		mix(
			n00,
			n10,
			u.x
		);

	float nx1 =
		mix(
			n01,
			n11,
			u.x
		);


	return mix(
		nx0,
		nx1,
		u.y
	);
}


// =====================================================
// FRACTAL BROWNIAN MOTION
// =====================================================

float fbm(vec2 p)
{
	float value = 0.0;

	float amplitude = 0.5;

	float frequency = 1.0;


	// octave 1
	value +=
		amplitude *
		gradient_noise(
			p * frequency
		);

	frequency *= 2.0;
	amplitude *= 0.5;


	// octave 2
	value +=
		amplitude *
		gradient_noise(
			p * frequency
		) * detail_strength;

	frequency *= 2.0;
	amplitude *= 0.5;


	// octave 3
	value +=
		amplitude *
		gradient_noise(
			p * frequency
		) * detail_strength;


	// Convert roughly from -1..1 into 0..1
	return value * 0.5 + 0.5;
}


// =====================================================
// CLOUD GENERATOR
// =====================================================

float make_cloud(
	vec2 uv,
	float scale,
	vec2 speed,
	float threshold,
	float softness,
	float time_offset
)
{
	vec2 p =
		uv * scale;


	// Slowly move the whole layer
	p +=
		speed * TIME;


	// Add slow organic distortion
	vec2 warp;

	warp.x =
		gradient_noise(
			p * 0.55
			+ vec2(
				TIME * distortion_speed,
				time_offset
			)
		);

	warp.y =
		gradient_noise(
			p * 0.55
			+ vec2(
				time_offset,
				TIME * distortion_speed
			)
		);


	p +=
		warp * distortion_strength;


	// Main cloud shape
	float noise_value =
		fbm(p);


	// Alpha mask
	float cloud_mask =
		smoothstep(
			threshold - softness,
			threshold + softness,
			noise_value
		);


	// Make the clouds softer and more "puffy"
	cloud_mask =
		pow(
			cloud_mask,
			1.35
		);


	return cloud_mask;
}


// =====================================================
// FRAGMENT
// =====================================================

void fragment()
{
	vec2 uv = UV;


	// Keep cloud proportions consistent on widescreen canvases
	float aspect =
		SCREEN_PIXEL_SIZE.y
		/
		SCREEN_PIXEL_SIZE.x;

	uv.x *= aspect;


	// =================================================
	// CLOUD LAYER 1
	// =================================================

	float cloud_1 =
		make_cloud(
			uv,
			cloud_scale_1,
			cloud_speed_1,
			cloud_threshold_1,
			cloud_softness_1,
			0.0
		);


	float alpha_1 =
		cloud_1
		* cloud_opacity_1
		* cloud_color_1.a;


	// =================================================
	// CLOUD LAYER 2
	// =================================================

	float cloud_2 =
		make_cloud(
			uv + vec2(17.4, 8.2),
			cloud_scale_2,
			cloud_speed_2,
			cloud_threshold_2,
			cloud_softness_2,
			19.7
		);


	float alpha_2 =
		cloud_2
		* cloud_opacity_2
		* cloud_color_2.a;


	// =================================================
	// COMBINE COLORS
	// =================================================

	vec3 combined_color =
		cloud_color_1.rgb * alpha_1
		+
		cloud_color_2.rgb * alpha_2;


	float combined_alpha =
		clamp(
			alpha_1 + alpha_2,
			0.0,
			1.0
		);


	combined_alpha *= master_opacity;


	// Avoid overly bright color when both layers overlap
	if (combined_alpha > 0.001)
	{
		combined_color /=
			max(
				alpha_1 + alpha_2,
				0.001
			);
	}


	COLOR =
		vec4(
			combined_color,
			combined_alpha
		);
}