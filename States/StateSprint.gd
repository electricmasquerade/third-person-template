extends StateBase
class_name StateSprint



func enter(player: Player):
	player.target_fov = player.default_fov + 10
	
	
func handle_input(player: Player, event: InputEvent):
	if event.is_action_pressed("jump") and player.is_on_floor():
		player.transition_to_state("jump")
		

func update(player, delta):
	

	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
		player.transition_to_state("fall")
		return

		
	# if sprint is released, swap to walking
	if not Input.is_action_pressed("sprint"):
		if player.move_direction.length_squared() > 0.01:
			player.transition_to_state("walk")
			return
		else:
			player.transition_to_state("idle")
			return
		
		
	if player.move_direction.length_squared() > 0.01:
		player.apply_horizontal_movement(player.stats.sprint_speed, delta)
	else:
		# If not walking, swap to idle. 
		player.transition_to_state("idle")
		return
	player.move_and_slide()

func exit(player: Player):
	player.target_fov = player.default_fov
