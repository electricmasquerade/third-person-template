extends StateBase
class_name StateJump

var airborne_time := 0.0
var airborne_limit := 0.1

func enter(player: Player):
	airborne_time = 0.0
	player.velocity.y = player.jump
	player.playback.travel("jump_start")

	

func update(player: Player, delta: float):
	airborne_time += delta
	player.velocity += player.get_gravity() * delta
	
	if player.move_direction.length_squared() > 0.01:
		player.velocity.x = player.move_direction.x * player.walk_speed
		player.velocity.z = player.move_direction.z * player.walk_speed
		player.mesh_pivot.rotation.y = lerp_angle(player.mesh_pivot.rotation.y, atan2(-player.velocity.x, -player.velocity.z), player.turn_speed * delta)
	
	if player.is_on_floor() and airborne_time > airborne_limit:
		player.playback.travel("jump_land")
		if player.move_direction.length_squared() > 0.01:
			player.transition_to_state("walk")
		else:
			player.transition_to_state("idle")
	
	
