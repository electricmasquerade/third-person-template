extends StateBase
class_name StateMantle

var previous_rm := Vector3.ZERO

func enter(player: Player):
	player.playback.travel("mantle")
	player.movement_col.disabled = true
	player.velocity.x = 0
	player.velocity.z = 0
	player.velocity.y = 0
	var face_dir = -player.chest_ray.get_collision_normal()
	player.mesh_pivot.rotation.y = atan2(-face_dir.x, -face_dir.z)
	player.mantle_target = player.target_ray.get_collision_point()
	player.velocity = Vector3.ZERO
	
func update(player: Player, delta: float):
	#print(player.anim_tree.get_root_motion_position())
	var motion = player.anim_tree.get_root_motion_position()
	var world_motion = player.mesh_pivot.global_basis * motion
	world_motion.x = -world_motion.x
	world_motion.z = -world_motion.z
	player.global_position += world_motion
	player.global_position += world_motion


	if player.playback.get_current_node() != "mantle":
		if player.move_direction.length_squared() > 0.01:
			player.transition_to_state("walk")
			return
		else:
			player.transition_to_state("idle")
			return
	player.move_and_slide()

func exit(player: Player):
	player.movement_col.disabled = false
