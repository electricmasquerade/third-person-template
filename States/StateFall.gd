extends StateBase
class_name StateFall

var airborne_time := 0.0
var current_max_speed := 0.0

func enter(player: Player):
	airborne_time = 0.0
	player.playback.travel("jump_loop")
	current_max_speed = Vector2(player.velocity.x, player.velocity.z).length()

func update(player: Player, delta: float):
	player.velocity += player.get_gravity() * delta
	airborne_time += delta
	
	var target = player.move_direction * max(current_max_speed, player.stats.walk_speed)

	if player.move_direction.length_squared() > 0.01:
		player.velocity.x = move_toward(player.velocity.x, target.x, player.stats.air_control * delta)
		player.velocity.z = move_toward(player.velocity.z, target.z, player.stats.air_control * delta)
		player.mesh_pivot.rotation.y = lerp_angle(player.mesh_pivot.rotation.y, atan2(-player.velocity.x, -player.velocity.z), player.stats.turn_speed * delta)
		
	player.move_and_slide()
	if player.check_for_mantle():
		player.transition_to_state("mantle") 
		return
		
	if player.is_on_floor() and airborne_time >= player.stats.land_limit:
		player.transition_to_state("land")
		return
	elif player.is_on_floor():
		if player.move_direction.length_squared() > 0.01:
			player.transition_to_state("walk")
			return
		else:
			player.transition_to_state("idle")
			return
	
	
