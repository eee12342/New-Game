shader_type canvas_item;


// =====================================================
// STAR TEXTURE
// =====================================================

// Your transparent PNG containing the stars.
// If this shader is directly on a TextureRect/Sprite2D,
// TEXTURE is used automatically.


// =====================================================
// MASTER SETTINGS
// =====================================================

// Overall opacity of the original image.
uniform float opacity : hint_range(0.0, 1.0, 0.01) = 1.0;


// How much brighter stars get when the noise passes over them.
uniform float brightness_boost : hint_range(0.0, 5.0, 0.01) = 1.5;


// How much more saturated the stars become.
uniform float saturation_boost : hint_range(0.0, 3.0, 0.01) = 1.5;


// =====================================================
// NOISE SETTINGS
// =====================================================

// Size of the moving noise pattern.
//
// Lower = huge broad waves
// Higher = smaller patches
uniform float noise_scale : hint_range(0.1, 20.0, 0.01) = 3.0;


// Movement speed of the noise.
uniform float noise_speed : hint_range(0.0, 2.0, 0.001) = 0.08;


// Direction the noise travels.
uniform vec2 noise_direction = vec2(1.0, 0.35);


// Controls how much of the noise activates the stars.
//
// Higher = fewer stars affected at once.
uniform float noise_threshold : hint_range(0.0, 1.0, 0.01) = 0.52;


// Controls softness of the moving noise edge.
uniform float noise_softness : hint_range(0.001, 0.5, 0.001) = 0.18;


// =====================================================
// TWINKLE / PULSE
// =====================================================

// Adds a subtle secondary flicker as the noise crosses stars.
uniform float twinkle_strength : hint_range(0.0, 1.0, 0.01) = 0.25;


// Speed of the secondary twinkle.
uniform float twinkle_speed : hint_range(0.0, 10.0, 0.01) = 2.0;


// =====================================================
// PERLIN-STYLE GRADIENT NOISE
// =====================================================

vec2 hash2(vec2 p)
{
	p = vec2(
		dot(p, vec2(127.1, 311.7)),
		dot(p, vec2(269.5, 183.3))
	);

	return -1.0
		+ 2.0
		* fract(
			sin(p)
			* 43758.5453123
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
// FRACTAL NOISE
// =====================================================

float fbm(vec2 p)
{
	float value = 0.0;
	float amplitude = 0.5;


	value +=
		gradient_noise(p)
		* amplitude;


	p *= 2.03;
	amplitude *= 0.5;

	value +=
		gradient_noise(p)
		* amplitude;


	p *= 2.01;
	amplitude *= 0.5;

	value +=
		gradient_noise(p)
		* amplitude;


	p *= 2.04;
	amplitude *= 0.5;

	value +=
		gradient_noise(p)
		* amplitude;


	// Convert approximately -1..1 to 0..1

	return value * 0.5 + 0.5;
}


// =====================================================
// SATURATION
// =====================================================

vec3 adjust_saturation(
	vec3 color,
	float saturation
)
{
	float luminance =
		dot(
			color,
			vec3(
				0.2126,
				0.7152,
				0.0722
			)
		);


	vec3 grayscale =
		vec3(luminance);


	return mix(
		grayscale,
		color,
		saturation
	);
}


// =====================================================
// FRAGMENT
// =====================================================

void fragment()
{
	// Read original pixel-art texture.

	vec4 tex =
		texture(
			TEXTURE,
			UV
		);


	// =================================================
	// ORIGINAL ALPHA MASK
	// =================================================

	// Transparent pixels remain completely transparent.
	// Only actual star pixels are modified.

	float star_mask =
		tex.a;


	// =================================================
	// MOVING NOISE
	// =================================================

	vec2 noise_uv =
		UV
		* noise_scale;


	noise_uv +=
		noise_direction
		* TIME
		* noise_speed;


	float noise_value =
		fbm(
			noise_uv
		);


	// Turn continuous noise into broad moving patches.

	float noise_mask =
		smoothstep(
			noise_threshold - noise_softness,
			noise_threshold + noise_softness,
			noise_value
		);


	// =================================================
	// ONLY APPLY EFFECT WHERE STARS EXIST
	// =================================================

	float effect =
		noise_mask
		* star_mask;


	// =================================================
	// SECONDARY TWINKLE
	// =================================================

	float twinkle =
		sin(
			TIME
			* twinkle_speed
			+
			noise_value
			* 12.0
		);


	twinkle =
		twinkle * 0.5 + 0.5;


	effect *=
		mix(
			1.0,
			twinkle,
			twinkle_strength
		);


	// =================================================
	// SATURATION
	// =================================================

	float saturation =
		1.0
		+
		effect
		* saturation_boost;


	vec3 final_color =
		adjust_saturation(
			tex.rgb,
			saturation
		);


	// =================================================
	// BRIGHTNESS
	// =================================================

	final_color *=
		1.0
		+
		effect
		* brightness_boost;


	// =================================================
	// OUTPUT
	// =================================================

	COLOR =
		vec4(
			final_color,
			tex.a * opacity
		);
}