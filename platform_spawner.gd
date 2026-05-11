extends Node2D

@export var platform_scene: PackedScene
const Platform_spacing = 600.0
var next_spawn_y = 600.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(80):
		spawn_platform(next_spawn_y)
		next_spawn_y -= Platform_spacing


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func spawn_platform(y: float):
	var platform = platform_scene.instantiate()
	var screen_width = get_viewport_rect().size.x
	var random_scale = randf_range(0.5, 1)
	platform.scale.x = random_scale
	platform.global_position = Vector2(randf_range(20, screen_width - 20), y)
	add_child(platform)
