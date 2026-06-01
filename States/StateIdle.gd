extends StateBase
class_name StateIdle

func enter(player: Player):
	player.playback.travel("locomotion")
	
func handle_input(player: Player, event: InputEvent):
	if event.is_action_pressed("jump") and player.is_on_floor():
		player.transition_to_state("jump")


func update(player: Player, delta: float):
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta

	# slow velocity to zero, otherwise swap to walking
	player.velocity.x = move_toward(player.velocity.x, 0, (player.walk_speed/0.01) * delta)
	player.velocity.z = move_toward(player.velocity.z, 0, (player.walk_speed/0.01) * delta)
	if player.move_direction.length_squared() > 0.01:
		player.transition_to_state("walk")
	
