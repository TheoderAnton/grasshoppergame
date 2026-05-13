extends CharacterBody2D

const SPEED = 1000.0
const JUMP_VELOCITY = -1200.0
const GRAVITY_MULTIPLIER = 1.0
const MAX_FALL_SPEED = 2000.0
const COYOTE_TIME = 0.12
const JUMP_BUFFER_TIME = 0.1
const WALL_SLIDE_SPEED = 150.0
const DASH_SPEED = 2500.0
const DASH_DURATION = 0.15
const DOUBLE_JUMP_VELOCITY = -1000.0
const TERMINAL_VELOCITY = 1800.0

@onready var camera = $Camera2D
@onready var hud = $"../HUD"
@onready var sprite = $Sprite2D

signal hit

var highest_y: float = 0.0
var is_dead = false

# Coyote Time System
var coyote_timer: float = 0.0
var was_on_floor: bool = false
var coyote_available: bool = false

# Jump Buffer System
var jump_buffer_timer: float = 0.0
var jump_buffered: bool = false

# Double Jump System
var double_jump_available: bool = true
var double_jump_count: int = 0
var max_double_jumps: int = 2
var double_jump_used: bool = false

# Dash System
var dash_available: bool = true
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: float = 1.0
var dash_cooldown: float = 0.0
var dash_cooldown_max: float = 0.8

# Wall Slide System
var is_wall_sliding: bool = false
var wall_jump_direction: float = 0.0
var wall_jump_available: bool = false
var wall_slide_timer: float = 0.0

# Combo System
var combo_count: int = 0
var combo_timer: float = 0.0
var combo_multiplier: float = 1.0
var last_combo_score: float = 0.0
var combo_active: bool = false

# Particle Trail System
var trail_timer: float = 0.0
var trail_interval: float = 0.05
var trail_particles_active: bool = false
var trail_intensity: float = 1.0

# Speed Boost System
var speed_boost_active: bool = false
var speed_boost_timer: float = 0.0
var speed_boost_multiplier: float = 1.5
var speed_boost_duration: float = 3.0

# Screen Shake System
var shake_intensity: float = 0.0
var shake_timer: float = 0.0
var shake_duration: float = 0.0
var shake_offset: Vector2 = Vector2.ZERO

# Invincibility System
var is_invincible: bool = false
var invincibility_timer: float = 0.0
var invincibility_duration: float = 1.5
var invincibility_flash_timer: float = 0.0

# Score Multiplier System
var score_multiplier: float = 1.0
var multiplier_timer: float = 0.0
var multiplier_active: bool = false
var base_score: float = 0.0

func _physics_process(delta: float) -> void:
	# --- FARB ANIMATION ---
	var t = (sin(Time.get_ticks_msec() * 0.01) + 1) / 2
	sprite.modulate = Color(0.0, 1.0, 0.0, 1.0).lerp(Color(0, 0, 1), t)

	# --- COYOTE TIME UPDATE ---
	if was_on_floor and not is_on_floor():
		coyote_timer = COYOTE_TIME
		coyote_available = true
	if coyote_timer > 0:
		coyote_timer -= delta
	else:
		coyote_available = false
	was_on_floor = is_on_floor()

	# --- JUMP BUFFER UPDATE ---
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
		jump_buffered = true
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	else:
		jump_buffered = false

	# --- DASH SYSTEM UPDATE ---
	if dash_cooldown > 0:
		dash_cooldown -= delta
	else:
		dash_available = true
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0
		if dash_timer <= 0:
			is_dashing = false
			dash_cooldown = dash_cooldown_max

	# --- WALL SLIDE UPDATE ---
	if is_on_wall() and not is_on_floor() and velocity.y > 0:
		is_wall_sliding = true
		wall_slide_timer += delta
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
		wall_jump_available = true
	else:
		is_wall_sliding = false
		wall_slide_timer = 0.0

	# --- COMBO SYSTEM UPDATE ---
	if combo_timer > 0:
		combo_timer -= delta
		combo_active = true
		combo_multiplier = 1.0 + (combo_count * 0.1)
	else:
		combo_active = false
		combo_count = 0
		combo_multiplier = 1.0

	# --- TRAIL SYSTEM UPDATE ---
	trail_timer += delta
	if trail_timer >= trail_interval:
		trail_timer = 0.0
		trail_particles_active = true
		trail_intensity = clamp(abs(velocity.x) / SPEED, 0.0, 1.0)
	else:
		trail_particles_active = false

	# --- SPEED BOOST UPDATE ---
	if speed_boost_active:
		speed_boost_timer -= delta
		if speed_boost_timer <= 0:
			speed_boost_active = false
			speed_boost_multiplier = 1.0

	# --- SCREEN SHAKE UPDATE ---
	if shake_timer > 0:
		shake_timer -= delta
		shake_intensity = shake_duration > 0 ? (shake_timer / shake_duration) * 8.0 : 0.0
		shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		camera.offset = shake_offset
	else:
		shake_offset = Vector2.ZERO
		camera.offset = Vector2.ZERO

	# --- INVINCIBILITY UPDATE ---
	if is_invincible:
		invincibility_timer -= delta
		invincibility_flash_timer += delta
		sprite.visible = fmod(invincibility_flash_timer, 0.1) < 0.05
		if invincibility_timer <= 0:
			is_invincible = false
			sprite.visible = true

	# --- SCORE MULTIPLIER UPDATE ---
	if multiplier_active:
		multiplier_timer -= delta
		if multiplier_timer <= 0:
			multiplier_active = false
			score_multiplier = 1.0


	coyote_available = false
	coyote_timer = 0.0
	jump_buffered = false
	jump_buffer_timer = 0.0
	double_jump_available = true
	double_jump_used = false
	double_jump_count = 0
	is_dashing = false
	dash_timer = 0.0
	dash_available = true
	dash_cooldown = 0.0
	is_wall_sliding = false
	wall_jump_available = false
	wall_slide_timer = 0.0
	combo_count = 0
	combo_timer = 0.0
	combo_multiplier = 1.0
	combo_active = false
	trail_particles_active = false
	trail_intensity = 0.0
	speed_boost_active = false
	speed_boost_timer = 0.0
	speed_boost_multiplier = 1.0
	shake_timer = 0.0
	shake_intensity = 0.0
	shake_offset = Vector2.ZERO
	camera.offset = Vector2.ZERO
	is_invincible = false
	invincibility_timer = 0.0
	sprite.visible = true
	multiplier_active = false
	score_multiplier = 1.0
	multiplier_timer = 0.0

	if not is_dead and not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")

	if direction and not is_dead:
		velocity.x += direction * SPEED * 0.6
		velocity.x = clamp(velocity.x, -SPEED, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	camera.position.x = 0

	var screen_width = get_viewport_rect().size.x

	if global_position.x > screen_width:
		global_position.x = 0
	if global_position.x < 0:
		global_position.x = screen_width

	if global_position.y < highest_y:
		highest_y = global_position.y
		hud.update_score(highest_y / -10.0)

	if not is_dead and global_position.y > highest_y + (get_viewport_rect().size.y * 0.8):
		is_dead = true
		velocity.y = 0
		hide()
		$"../HUD/Button".show()
		hit.emit()

func _on_button_pressed() -> void:
	show()
	is_dead = false
	position.x = 321
	position.y = 74
	highest_y = 0
	$"../HUD/Button".hide()
	pass
