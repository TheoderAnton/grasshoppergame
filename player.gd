extends CharacterBody2D


const SPEED = 1000.0
const JUMP_VELOCITY = -1200.0
@onready var camera = $Camera2D
var highest_y: float = 0.0
@onready var hud = $"../HUD"
signal hit
var is_dead = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	var t = (sin(Time.get_ticks_msec()* 0.01)+1) / 2
	$Sprite2D.modulate = Color(0.0, 1.0, 0.0, 1.0).lerp(Color(0,0,1),t)
	
	if not is_dead and not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
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
		
		#$Sprite2D.rotation_degrees = 180
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
	pass # Replace with function body.
