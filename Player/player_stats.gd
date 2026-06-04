extends Resource
class_name PlayerStats

@export_group("Movement")
@export var walk_speed := 5.0
@export var sprint_speed := 10.0
@export var turn_speed := 25.0 #speed the player turns towards the camera direction
@export var accel_time := 0.1

@export_group("Air Movement")
@export var jump := 4.5
@export var air_control := 15.0
@export var rise_gravity_scale := 1.5
@export var land_limit := 1.0
