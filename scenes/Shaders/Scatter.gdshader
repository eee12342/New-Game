shader_type canvas_item;


// =====================================================
// FEATURES
// =====================================================

#define USE_ROTATION 1
#define USE_COLOR_MODULATION 1


// =====================================================
// SCATTER SETTINGS
// =====================================================

group_uniforms Scatter;

uniform float random_seed = 0.0;

// Number of potential scatter locations.
// Increase this for MORE possible objects.
uniform vec2 grid_size = vec2(24.0, 14.0);

uniform vec2 cell_offset = vec2(0.0, 0.0);

// Movement of the entire field.
uniform vec2 movement_speed = vec2(0.0, 0.0);

// Percentage of cells that actually contain an object.
//
// 0.10 = sparse
// 0.30 = moderate
// 0.60 = dense
// 1.00 = every cell
uniform float density : hint_range(0.0, 1.0, 0.01) = 0.50;


// =====================================================
// SIZE
// =====================================================

group_uniforms Size;

uniform float size_min : hint_range(0.01, 1.0, 0.01) = 0.10;

uniform float size_max : hint_range(0.01, 1.0, 0.01) = 0.35;


// =====================================================
// SPRITES
// =====================================================

group_uniforms Sprites;

// YOU SHOULD SEE ALL FOUR OF THESE IN THE INSPECTOR

uniform sampler2D sprite_1_texture;

uniform sampler2D sprite_2_texture;

uniform sampler2D sprite_3_texture;

uniform sampler2D sprite_4_texture;


// =====================================================
// SPRITE FREQUENCY
// =====================================================

group_uniforms Sprite_Mix;

// Higher weight = that sprite appears more often.
//
// All at 1.0 = roughly equal distribution.

uniform float sprite_1_weight :
	hint_range(0.0, 10.0, 0.01) = 1.0;

uniform float sprite_2_weight :
	hint_range(0.0, 10.0, 0.01) = 1.0;

uniform float sprite_3_weight :
	hint_range(0.0, 10.0, 0.01) = 1.0;

uniform float sprite_4_weight :
	hint_range(0.0, 10.0, 0.01) = 1.0;


// =====================================================
// OPACITY
// =====================================================

group_uniforms Appearance;

uniform float opacity :
	hint_range(0.0, 1.0, 0.01) = 1.0;


// =====================================================
// COLOR MODULATION
// =====================================================

#if USE_COLOR_MODULATION

uniform vec4 color_a : source_color =
	vec4(1.0, 1.0, 1.0, 1.0);

uniform vec4 color_b : source_color =
	vec4(1.0, 1.0, 1.0, 1.0);

#endif


// =====================================================
// ROTATION
// =====================================================

#if USE_ROTATION

group_uniforms Rotation;

const float INV_SQRT2 = 0.70710678118;

uniform float rotation_global_speed = 1.0;

uniform float rotation_min_speed :
	hint_range(0.0, 3.0, 0.01) = 0.10;

uniform float rotation_max_speed :
	hint_range(0.0, 3.0, 0.01) = 1.00;

#endif


// =====================================================
// END GROUPING
// =====================================================

group_uniforms;


// =====================================================
// RANDOM
// =====================================================

float random_value(vec2 p)
{
	return fract(
		sin(
			dot(
				p,
				vec2(12.9898, 78.233)
			)
		)
		* 43758.5453
	);
}


// =====================================================
// ROTATION
// =====================================================

#if USE_ROTATION

vec2 rotate_uv(
	vec2 uv,
	vec2 pivot,
	float angle
)
{
	float s = sin(angle);
	float c = cos(angle);

	uv -= pivot;

	uv =
		mat2(
			vec2(c, -s),
			vec2(s, c)
		)
		* uv;

	uv += pivot;

	return uv;
}

#endif


// =====================================================
// SAMPLE ONE OF FOUR SPRITES
// =====================================================

vec4 sample_selected_sprite(
	vec2 sprite_uv,
	float selector
)
{
	float total_weight =
		sprite_1_weight +
		sprite_2_weight +
		sprite_3_weight +
		sprite_4_weight;


	// Prevent bad math if all weights are zero.
	if (total_weight <= 0.0001)
	{
		return vec4(0.0);
	}


	float value =
		selector * total_weight;


	float cutoff_1 =
		sprite_1_weight;


	float cutoff_2 =
		cutoff_1 +
		sprite_2_weight;


	float cutoff_3 =
		cutoff_2 +
		sprite_3_weight;


	// -------------------------------------------------
	// SPRITE 1
	// -------------------------------------------------

	if (value < cutoff_1)
	{
		return texture(
			sprite_1_texture,
			sprite_uv
		);
	}


	// -------------------------------------------------
	// SPRITE 2
	// -------------------------------------------------

	if (value < cutoff_2)
	{
		return texture(
			sprite_2_texture,
			sprite_uv
		);
	}


	// -------------------------------------------------
	// SPRITE 3
	// -------------------------------------------------

	if (value < cutoff_3)
	{
		return texture(
			sprite_3_texture,
			sprite_uv
		);
	}


	// -------------------------------------------------
	// SPRITE 4
	// -------------------------------------------------

	return texture(
		sprite_4_texture,
		sprite_uv
	);
}


// =====================================================
// DRAW SINGLE OBJECT
// =====================================================

vec4 draw_object(
	vec4 background,
	vec2 local_uv,
	vec2 center,
	float object_size,
	float rotation_speed,
	vec4 tint,
	float sprite_selector
)
{
	vec2 object_uv =
		(local_uv - center)
		/ object_size
		+ vec2(0.5);


#if USE_ROTATION

	object_uv =
		rotate_uv(
			object_uv,
			vec2(0.5),
			TIME * rotation_speed
		);

#endif


	// Outside object bounds.
	if (
		object_uv.x < 0.0 ||
		object_uv.x > 1.0 ||
		object_uv.y < 0.0 ||
		object_uv.y > 1.0
	)
	{
		return background;
	}


	vec4 sprite_color =
		sample_selected_sprite(
			object_uv,
			sprite_selector
		);


	return sprite_color * tint;
}


// =====================================================
// SCATTER
// =====================================================

vec4 scatter_layer(
	vec4 background,
	vec2 uv
)
{
	// -------------------------------------------------
	// CREATE GRID
	// -------------------------------------------------

	vec2 moving_grid =
		(uv * grid_size)
		-
		(movement_speed * TIME)
		+
		cell_offset;


	vec2 cell =
		floor(
			moving_grid
		);


	vec2 local_uv =
		fract(
			moving_grid
		);


	// -------------------------------------------------
	// DENSITY
	// -------------------------------------------------

	float population_random =
		random_value(
			cell
			+
			vec2(
				random_seed + 31.41,
				random_seed + 73.27
			)
		);


	if (population_random > density)
	{
		return background;
	}


	// -------------------------------------------------
	// SELECT RANDOM SPRITE
	// -------------------------------------------------

	float sprite_selector =
		random_value(
			cell
			+
			vec2(
				random_seed + 157.21,
				random_seed + 291.73
			)
		);


	// -------------------------------------------------
	// RANDOM SIZE
	// -------------------------------------------------

	float size_random =
		random_value(
			cell
			+
			vec2(
				random_seed + 11.23,
				random_seed + 19.47
			)
		);


#if USE_ROTATION

	float object_size =
		mix(
			size_min,
			min(
				size_max,
				INV_SQRT2
			),
			size_random
		);


	float margin =
		object_size
		* INV_SQRT2;

#else

	float object_size =
		mix(
			size_min,
			size_max,
			size_random
		);


	float margin =
		object_size
		* 0.5;

#endif


	// -------------------------------------------------
	// RANDOM POSITION IN CELL
	// -------------------------------------------------

	float position_random_x =
		random_value(
			cell
			+
			vec2(
				random_seed + 41.91,
				random_seed + 67.13
			)
		);


	float position_random_y =
		random_value(
			cell
			+
			vec2(
				random_seed + 83.17,
				random_seed + 109.43
			)
		);


	vec2 center =
		vec2(
			mix(
				margin,
				1.0 - margin,
				position_random_x
			),

			mix(
				margin,
				1.0 - margin,
				position_random_y
			)
		);


	// -------------------------------------------------
	// ROTATION
	// -------------------------------------------------

	float object_rotation_speed = 0.0;


#if USE_ROTATION

	float direction_random =
		random_value(
			cell
			+
			vec2(
				random_seed + 137.91,
				random_seed + 173.53
			)
		);


	float direction =
		direction_random < 0.5
		? -1.0
		: 1.0;


	float rotation_random =
		random_value(
			cell
			+
			vec2(
				random_seed + 211.73,
				random_seed + 257.37
			)
		);


	object_rotation_speed =
		direction
		*
		rotation_global_speed
		*
		mix(
			rotation_min_speed,
			rotation_max_speed,
			rotation_random
		);

#endif


	// -------------------------------------------------
	// COLOR
	// -------------------------------------------------

	vec4 tint =
		vec4(1.0);


#if USE_COLOR_MODULATION

	float tint_random =
		random_value(
			cell
			+
			vec2(
				random_seed + 307.31,
				random_seed + 353.87
			)
		);


	tint =
		mix(
			color_a,
			color_b,
			tint_random
		);

#endif


	// -------------------------------------------------
	// DRAW
	// -------------------------------------------------

	return draw_object(
		background,
		local_uv,
		center,
		object_size,
		object_rotation_speed,
		tint,
		sprite_selector
	);
}


// =====================================================
// FRAGMENT
// =====================================================

void fragment()
{
	vec4 color =
		vec4(0.0);


	color =
		scatter_layer(
			color,
			UV
		);


	color.a *= opacity;


	COLOR =
		color;
}