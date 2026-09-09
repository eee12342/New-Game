shader_type canvas_item;


// =====================================================
// FEATURES
// =====================================================

#define USE_ROTATION 1
#define USE_COLOR_MODULATION 1


// =====================================================
// SCATTER
// =====================================================

group_uniforms Scatter;

uniform float random_seed = 0.0;

uniform vec2 grid_size = vec2(24.0, 14.0);

uniform vec2 cell_offset = vec2(0.0);

uniform vec2 movement_speed = vec2(0.0);

uniform float density :
	hint_range(0.0, 1.0, 0.01) = 0.50;


// =====================================================
// INDIVIDUAL DRIFT
// =====================================================

group_uniforms Individual_Drift;

uniform float drift_amount_min :
	hint_range(0.0, 0.5, 0.001) = 0.01;

uniform float drift_amount_max :
	hint_range(0.0, 0.5, 0.001) = 0.06;

uniform float drift_speed_min :
	hint_range(0.0, 3.0, 0.01) = 0.15;

uniform float drift_speed_max :
	hint_range(0.0, 3.0, 0.01) = 0.50;


// =====================================================
// SIZE
// =====================================================

group_uniforms Size;

uniform float size_min :
	hint_range(0.05, 2.5, 0.01) = 0.60;

uniform float size_max :
	hint_range(0.05, 2.5, 0.01) = 1.20;


// =====================================================
// SPRITES
// =====================================================

group_uniforms Sprites;

uniform sampler2D sprite_1_texture :
	filter_nearest,
	repeat_disable;

uniform sampler2D sprite_2_texture :
	filter_nearest,
	repeat_disable;

uniform sampler2D sprite_3_texture :
	filter_nearest,
	repeat_disable;

uniform sampler2D sprite_4_texture :
	filter_nearest,
	repeat_disable;


// =====================================================
// SPRITE MIX
// =====================================================

group_uniforms Sprite_Mix;

uniform float sprite_1_weight :
	hint_range(0.0, 10.0, 0.01) = 1.0;

uniform float sprite_2_weight :
	hint_range(0.0, 10.0, 0.01) = 1.0;

uniform float sprite_3_weight :
	hint_range(0.0, 10.0, 0.01) = 1.0;

uniform float sprite_4_weight :
	hint_range(0.0, 10.0, 0.01) = 1.0;


// =====================================================
// APPEARANCE
// =====================================================

group_uniforms Appearance;

uniform float opacity :
	hint_range(0.0, 1.0, 0.01) = 1.0;


#if USE_COLOR_MODULATION

uniform vec4 color_a : source_color =
	vec4(1.0);

uniform vec4 color_b : source_color =
	vec4(1.0);

#endif


// =====================================================
// ROTATION
// =====================================================

#if USE_ROTATION

group_uniforms Rotation;

uniform float rotation_global_speed = 1.0;

uniform float rotation_min_speed :
	hint_range(0.0, 3.0, 0.01) = 0.10;

uniform float rotation_max_speed :
	hint_range(0.0, 3.0, 0.01) = 1.00;

#endif


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
// ROTATE UV
// =====================================================

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


// =====================================================
// SELECT SPRITE
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


	if (value < cutoff_1)
	{
		return texture(
			sprite_1_texture,
			sprite_uv
		);
	}


	if (value < cutoff_2)
	{
		return texture(
			sprite_2_texture,
			sprite_uv
		);
	}


	if (value < cutoff_3)
	{
		return texture(
			sprite_3_texture,
			sprite_uv
		);
	}


	return texture(
		sprite_4_texture,
		sprite_uv
	);
}


// =====================================================
// DRAW OBJECT FROM A SPECIFIC CELL
// =====================================================

vec4 draw_cell_object(
	vec2 current_local_uv,
	vec2 base_cell,
	vec2 neighbor_offset
)
{
	vec2 cell =
		base_cell +
		neighbor_offset;


	// -------------------------------------------------
	// DENSITY
	// -------------------------------------------------

	float population_random =
		random_value(
			cell +
			vec2(
				random_seed + 31.41,
				random_seed + 73.27
			)
		);


	if (population_random > density)
	{
		return vec4(0.0);
	}


	// -------------------------------------------------
	// SPRITE
	// -------------------------------------------------

	float sprite_selector =
		random_value(
			cell +
			vec2(
				random_seed + 157.21,
				random_seed + 291.73
			)
		);


	// -------------------------------------------------
	// SIZE
	// -------------------------------------------------

	float size_random =
		random_value(
			cell +
			vec2(
				random_seed + 11.23,
				random_seed + 19.47
			)
		);


	float object_size =
		mix(
			size_min,
			size_max,
			size_random
		);


	// -------------------------------------------------
	// RANDOM BASE POSITION
	// -------------------------------------------------

	float px =
		random_value(
			cell +
			vec2(
				random_seed + 41.91,
				random_seed + 67.13
			)
		);


	float py =
		random_value(
			cell +
			vec2(
				random_seed + 83.17,
				random_seed + 109.43
			)
		);


	vec2 center =
		neighbor_offset +
		vec2(
			mix(0.15, 0.85, px),
			mix(0.15, 0.85, py)
		);


	// -------------------------------------------------
	// INDIVIDUAL DRIFT AMOUNT
	// -------------------------------------------------

	float drift_x_random =
		random_value(
			cell +
			vec2(
				random_seed + 401.13,
				random_seed + 437.79
			)
		);


	float drift_y_random =
		random_value(
			cell +
			vec2(
				random_seed + 479.31,
				random_seed + 523.67
			)
		);


	float drift_x =
		mix(
			drift_amount_min,
			drift_amount_max,
			drift_x_random
		);


	float drift_y =
		mix(
			drift_amount_min,
			drift_amount_max,
			drift_y_random
		);


	// -------------------------------------------------
	// INDIVIDUAL SPEED
	// -------------------------------------------------

	float speed_x_random =
		random_value(
			cell +
			vec2(
				random_seed + 571.27,
				random_seed + 613.91
			)
		);


	float speed_y_random =
		random_value(
			cell +
			vec2(
				random_seed + 661.47,
				random_seed + 709.33
			)
		);


	float speed_x =
		mix(
			drift_speed_min,
			drift_speed_max,
			speed_x_random
		);


	float speed_y =
		mix(
			drift_speed_min,
			drift_speed_max,
			speed_y_random
		);


	// -------------------------------------------------
	// INDIVIDUAL PHASE
	// -------------------------------------------------

	float phase_x =
		random_value(
			cell +
			vec2(
				random_seed + 751.91,
				random_seed + 797.43
			)
		)
		* 6.283185;


	float phase_y =
		random_value(
			cell +
			vec2(
				random_seed + 839.17,
				random_seed + 887.69
			)
		)
		* 6.283185;


	// -------------------------------------------------
	// ADD DRIFT
	// -------------------------------------------------

	center +=
		vec2(
			sin(
				TIME * speed_x +
				phase_x
			)
			* drift_x,

			cos(
				TIME * speed_y +
				phase_y
			)
			* drift_y
		);


	// -------------------------------------------------
	// OBJECT UV
	// -------------------------------------------------

	vec2 object_uv =
		(
			current_local_uv -
			center
		)
		/
		object_size
		+
		vec2(0.5);


	// -------------------------------------------------
	// ROTATION
	// -------------------------------------------------

#if USE_ROTATION

	float direction_random =
		random_value(
			cell +
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
			cell +
			vec2(
				random_seed + 211.73,
				random_seed + 257.37
			)
		);


	float rotation_speed =
		direction
		*
		rotation_global_speed
		*
		mix(
			rotation_min_speed,
			rotation_max_speed,
			rotation_random
		);


	object_uv =
		rotate_uv(
			object_uv,
			vec2(0.5),
			TIME * rotation_speed
		);

#endif


	// -------------------------------------------------
	// OUTSIDE OBJECT
	// -------------------------------------------------

	if (
		object_uv.x < 0.0 ||
		object_uv.x > 1.0 ||
		object_uv.y < 0.0 ||
		object_uv.y > 1.0
	)
	{
		return vec4(0.0);
	}


	// -------------------------------------------------
	// SAMPLE SPRITE
	// -------------------------------------------------

	vec4 sprite_color =
		sample_selected_sprite(
			object_uv,
			sprite_selector
		);


	// -------------------------------------------------
	// COLOR
	// -------------------------------------------------

#if USE_COLOR_MODULATION

	float tint_random =
		random_value(
			cell +
			vec2(
				random_seed + 307.31,
				random_seed + 353.87
			)
		);


	vec4 tint =
		mix(
			color_a,
			color_b,
			tint_random
		);


	sprite_color *= tint;

#endif


	return sprite_color;
}


// =====================================================
// ALPHA COMPOSITE
// =====================================================

vec4 alpha_over(
	vec4 bottom,
	vec4 top
)
{
	float out_alpha =
		top.a +
		bottom.a *
		(1.0 - top.a);


	vec3 out_rgb =
		top.rgb * top.a +
		bottom.rgb *
		bottom.a *
		(1.0 - top.a);


	if (out_alpha > 0.0001)
	{
		out_rgb /= out_alpha;
	}


	return vec4(
		out_rgb,
		out_alpha
	);
}


// =====================================================
// FRAGMENT
// =====================================================

void fragment()
{
	vec2 moving_grid =
		(UV * grid_size)
		-
		(movement_speed * TIME)
		+
		cell_offset;


	vec2 base_cell =
		floor(
			moving_grid
		);


	vec2 local_uv =
		fract(
			moving_grid
		);


	vec4 final_color =
		vec4(0.0);


	// =================================================
	// CHECK 5x5 SURROUNDING CELLS
	// =================================================
	//
	// This is the important fix.
	//
	// An asteroid can now belong to a neighboring cell
	// and still draw into THIS pixel.
	//
	// Therefore drifting and large sprites are no longer
	// chopped at cell boundaries.
	// =================================================

	for (int y = -2; y <= 2; y++)
	{
		for (int x = -2; x <= 2; x++)
		{
			vec2 offset =
				vec2(
					float(x),
					float(y)
				);


			vec4 object_color =
				draw_cell_object(
					local_uv,
					base_cell,
					offset
				);


			final_color =
				alpha_over(
					final_color,
					object_color
				);
		}
	}


	final_color.a *=
		opacity;


	COLOR =
		final_color;
}