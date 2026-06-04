extends StateBase
class_name StateLand

func enter(player: Player):
	player.playback.travel("jump_land")
	
	player.velocity.x = 0
	player.velocity.z = 0
	

	

func update(player: Player, delta: float):
	player.velocity += player.get_gravity() * delta

	if player.playback.get_current_node() != "jump_land":
		if player.move_direction.length_squared() > 0.01:
			player.transition_to_state("walk")
			return
		else:
			player.transition_to_state("idle")
			return
	
