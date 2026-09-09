shader_type canvas_item;


// ================================
// RAINBOW
// ================================

uniform float rainbow_speed : hint_range(0.0, 3.0) = 0.35;
uniform float rainbow_strength : hint_range(0.0, 1.0) = 0.75;


// ================================
// BRIGHTNESS / GLOW
// ================================

uniform float brightness : hint_range(1.0, 8.0) = 3.0;


// ================================
// FLOATING MOVEMENT
// ================================

uniform float float_amount : hint_range(0.0, 30.0) = 8.0;
uniform float float_speed : hint_range(0.0, 3.0) = 0.7;


// ================================
// SUBTLE WOBBLE
// ================================

uniform float wobble_amount : hint_range(0.0, 0.05) = 0.008;
uniform float wobble_speed : hint_range(0.0, 5.0) = 1.2;


// ================================
// SHINE
// ================================

uniform float shine_speed : hint_range(0.1, 5.0) = 1.0;
uniform float shine_width : hint_range(0.01, 0.5) = 0.12;
uniform float shine_strength : hint_range(0.0, 8.0) = 4.0;
uniform float shine_interval : hint_range(1.0, 15.0) = 5.0;


// ================================
// HSV -> RGB
// ================================

vec3 hsv_to_rgb(vec3 c) {
	vec3 rgb = clamp(
		abs(
			mod(
				c.x * 6.0 + vec3(0.0, 4.0, 2.0),
				6.0
			) - 3.0
		) - 1.0,
		0.0,
		1.0
	);

	rgb = rgb * rgb * (3.0 - 2.0 * rgb);

	return c.z * mix(
		vec3(1.0),
		rgb,
		c.y
	);
}


// ================================
// VERTEX ANIMATION
// ================================

void vertex() {

	// Gentle horizontal movement.
	float x_move =
		sin(TIME * float_speed)
		* float_amount;

	// Slightly different vertical timing
	// keeps it from looking mechanical.
	float y_move =
		cos(TIME * float_speed * 0.73)
		* float_amount;

	VERTEX += vec2(
		x_move,
		y_move
	);


	// Very subtle organic wobble.
	float wobble =
		sin(
			TIME * wobble_speed
			+ VERTEX.y * 0.015
		)
		* wobble_amount;

	VERTEX.x += wobble * 100.0;
}


// ================================
// PIXEL EFFECT
// ================================

void fragment() {

	vec4 tex = texture(TEXTURE, UV);


	// ----------------------------
	// RAINBOW
	// ----------------------------

	float hue =
		fract(
			UV.x * 0.45
			+ UV.y * 0.25
			+ TIME * rainbow_speed
		);

	vec3 rainbow =
		hsv_to_rgb(
			vec3(
				hue,
				1.0,
				1.0
			)
		);


	// Mix original artwork with rainbow.
	vec3 final_color =
		mix(
			tex.rgb,
			tex.rgb * rainbow,
			rainbow_strength
		);


	// ----------------------------
	// BREATHING / PULSE
	// ----------------------------

	float pulse =
		1.0
		+ sin(TIME * 1.7)
		* 0.12;


	// ----------------------------
	// PERIODIC SHINE
	// ----------------------------

	float cycle =
		mod(
			TIME,
			shine_interval
		);


	float shine_progress =
		clamp(
			cycle * shine_speed,
			0.0,
			1.0
		);


	// Makes the shine diagonal.
	float diagonal_uv =
		UV.x
		+ UV.y * 0.35;


	// Start outside the left edge
	// and travel past the right edge.
	float shine_position =
		shine_progress * 1.7
		- 0.35;


	float distance_to_shine =
		abs(
			diagonal_uv
			- shine_position
		);


	float shine =
		1.0
		- smoothstep(
			0.0,
			shine_width,
			distance_to_shine
		);


	// Turn shine off after sweep finishes.
	float shine_active =
		1.0
		- step(
			1.0,
			cycle * shine_speed
		);

	shine *= shine_active;


	// Add white-hot shine.
	final_color +=
		vec3(1.0)
		* shine
		* shine_strength;


	// ----------------------------
	// HDR BRIGHTNESS
	// ----------------------------

	final_color *=
		brightness
		* pulse;


	// Keep original transparency.
	COLOR = vec4(
		final_color,
		tex.a
	);
}