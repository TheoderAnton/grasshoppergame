extends CanvasLayer
@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_score(meters:float):
	label.text = str(int(meters)) + "m"


func _on_player_hit() -> void:
	show()
	pass # Replace with function body.
