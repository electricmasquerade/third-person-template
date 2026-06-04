extends CharacterBody3D
class_name Player

@export var stats : PlayerStats
var move_direction := Vector3.ZERO
@onready var mesh_pivot: Node3D = $MeshPivot
@onready var movement_col: CollisionShape3D = $MovementCol



#camera variables
@onready var cam_yaw_pivot: Node3D = $CamYaw
@onready var cam_pitch_pivot: Node3D = $CamYaw/CamPitch
var cam_yaw: float = 0.0
var cam_pitch: float = 0.0
@onready var third_per_cam: Camera3D = $CamYaw/CamPitch/SpringArm3D/ThirdPerCam
@export var gamepad_sensitivity: float = 0.1
@export var mouse_sensitivity: float = 0.002
@export var look_sensitivity: float = 0.01
@export var look_deadzone: float = 0.1

@export var smoothing: float = 5.0
@export var default_fov := 80.0
var target_fov := 80.0
@export var fov_speed := 10.0

#raycasts for mantle check
@onready var head_ray: RayCast3D = $MeshPivot/HeadRay
@onready var chest_ray: RayCast3D = $MeshPivot/ChestRay
@onready var target_ray: RayCast3D = $MeshPivot/MantleTarget #probably going to be unused
var mantle_target := Vector3.ZERO


# state stuff

@onready var states: Dictionary[String, StateBase] = {
	"idle": StateIdle.new(),
	"walk": StateWalk.new(),
	"sprint": StateSprint.new(),
	"jump": StateJump.new(),
	"fall": StateFall.new(),
	"mantle": StateMantle.new(),
	"land": StateLand.new()
	}
@onready var current_state := "idle"

# animation stuff
@onready var anim_tree: AnimationTree = $MeshPivot/UAL1_Standard/AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")

func _ready() -> void:
	states[current_state].enter(self)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		cam_yaw += -event.relative.x * look_sensitivity
		cam_pitch += -event.relative.y * look_sensitivity 
		cam_pitch = clamp(cam_pitch, deg_to_rad(-70), deg_to_rad(65))
		
	states[current_state].handle_input(self, event)


func _physics_process(delta: float) -> void:
	var direction := compute_move_direction()
	move_direction = direction
	handle_camera(delta)
	states[current_state].update(self, delta)
	update_animation(delta)
	

func handle_camera(delta):
	var axis_vector: Vector2 = Vector2.ZERO
	axis_vector.x  = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axis_vector.y  = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	if axis_vector.length() > look_deadzone:
		# Handle gamepad input for camera rotation.
		cam_pitch += -axis_vector.y * gamepad_sensitivity
		cam_yaw += -axis_vector.x * gamepad_sensitivity
		cam_pitch = clamp(cam_pitch, deg_to_rad(-80), deg_to_rad(65))
			
	cam_pitch_pivot.rotation.x = lerp_angle(cam_pitch_pivot.rotation.x, cam_pitch, smoothing * delta)
	cam_yaw_pivot.rotation.y = lerp_angle(cam_yaw_pivot.rotation.y, cam_yaw, smoothing * delta)
	
	third_per_cam.fov = lerp(third_per_cam.fov, target_fov, fov_speed * delta)

func compute_move_direction() -> Vector3:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (cam_yaw_pivot.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	return direction
	
	
func transition_to_state(state: String) -> void:
	if states.has(state):
		print(state)
		states[current_state].exit(self)
		current_state = state
		states[current_state].enter(self)
	else:
		push_error("State " + state + " does not exist in the state machine.")

func update_animation(delta):
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	anim_tree.set("parameters/locomotion/blend_position", horizontal_speed)

func apply_horizontal_movement(target_speed, delta):
	velocity.x = move_toward(velocity.x, move_direction.x * target_speed, target_speed/stats.accel_time * delta)
	velocity.z = move_toward(velocity.z, move_direction.z * target_speed, target_speed/stats.accel_time * delta)
	mesh_pivot.rotation.y = lerp_angle(mesh_pivot.rotation.y, atan2(-velocity.x, -velocity.z), stats.turn_speed * delta)

func check_for_mantle():
	if chest_ray.is_colliding() and not head_ray.is_colliding():
		if move_direction.length_squared() > 0.01 and move_direction.dot(-chest_ray.get_collision_normal()) > 0.0:
			return true
