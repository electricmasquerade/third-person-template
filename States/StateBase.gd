extends Node
class_name StateBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func enter(player: Player):
	pass
	
func exit(player: Player):
	pass
	
func handle_input(player: Player, event):
	pass
	
func update(player: Player, delta: float):
	pass
