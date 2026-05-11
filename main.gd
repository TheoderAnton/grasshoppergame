extends Node


func _ready() -> void:
	pass
	
	
func _process(_delta: float) -> void:
	pass


func _on_player_hit() -> void:
	$GPUParticles2D.global_position = $Player.global_position
	$GPUParticles2D.restart()
