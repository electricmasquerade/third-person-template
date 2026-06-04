extends StateBase
class_name StateJump

var airborne_time := 0.0
var airborne_limit := 0.1
var current_max_speed := 0.0

func enter(player: Player):
	airborne_time = 0.0
	player.velocity.y = player.stats.jump
	player.playback.travel("jump_start")
	current_max_speed = Vector2(player.velocity.x, player.velocity.z).length()

	

func update(player: Player, delta: float):
	airborne_time += delta
	player.velocity += player.get_gravity()/player.stats.rise_gravity_scale * delta
	#print(player.chest_ray.get_collider())
	
	if player.move_direction.length_squared() > 0.01:
		# Use air control while jumping or falling
		var target = player.move_direction * max(current_max_speed, player.stats.walk_speed)
		player.velocity.x = move_toward(player.velocity.x, target.x, player.stats.air_control * delta)
		player.velocity.z = move_toward(player.velocity.z, target.z, player.stats.air_control * delta)
		player.mesh_pivot.rotation.y = lerp_angle(player.mesh_pivot.rotation.y, atan2(-player.velocity.x, -player.velocity.z), player.stats.turn_speed * delta)
	else:
		var target = player.move_direction * player.stats.walk_speed
		player.velocity.x = move_toward(player.velocity.x, target.x, player.stats.air_control * delta)
		player.velocity.z = move_toward(player.velocity.z, target.z, player.stats.air_control * delta)
		player.mesh_pivot.rotation.y = lerp_angle(player.mesh_pivot.rotation.y, atan2(-player.velocity.x, -player.velocity.z), player.stats.turn_speed * delta)


	#check raycasts for mantling
	if player.check_for_mantle():
		player.transition_to_state("mantle") 
		return

	player.move_and_slide()
	# Once velocity becomes negative, swap to fall state
	if player.velocity.y < 0:
		player.transition_to_state("fall")
		return
	if player.is_on_floor() and airborne_time > airborne_limit:
		player.playback.travel("jump_land")
		if player.move_direction.length_squared() > 0.01:
			player.transition_to_state("walk")
			return
		else:
			player.transition_to_state("idle")
			return
	
	
