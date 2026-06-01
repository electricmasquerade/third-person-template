extends StateBase
class_name StateWalk

func enter(player: Player):
	player.playback.travel("locomotion")
	
	
func handle_input(player: Player, event: InputEvent):
	if event.is_action_pressed("jump") and player.is_on_floor():
		player.transition_to_state("jump")
		

func update(player, delta):
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
		
	if player.move_direction.length_squared() > 0.01:
		#player.velocity.x = move_toward(player.velocity.x, 0, (player.walk_speed/0.1) * delta)

		player.velocity.x = player.move_direction.x * player.walk_speed
		player.velocity.z = player.move_direction.z * player.walk_speed
		player.mesh_pivot.rotation.y = lerp_angle(player.mesh_pivot.rotation.y, atan2(-player.velocity.x, -player.velocity.z), player.turn_speed * delta)
	else:
		# If not walking, swap to idle. 
		player.transition_to_state("idle")
