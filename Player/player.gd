extends CharacterBody3D
class_name Player

@export var walk_speed: float = 5.0
@export var run_speed: float = 10.0
@export var jump: float = 4.5
var move_direction := Vector3.ZERO
@onready var mesh_pivot: Node3D = $MeshPivot



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
@export var turn_speed: float = 25.0 #speed the player turns towards the camera direction

# state stuff
var current_state := "idle"
var states: Dictionary[Variant, Variant] = {
	"idle": StateIdle.new(),
	"walk": StateWalk.new()
	}


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		cam_yaw += -event.relative.x * look_sensitivity
		cam_pitch += -event.relative.y * look_sensitivity 
		cam_pitch = clamp(cam_pitch, deg_to_rad(-70), deg_to_rad(65))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump
		
	if Input.is_action_just_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var direction := compute_move_direction()
	if direction:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
		mesh_pivot.rotation.y = lerp_angle(mesh_pivot.rotation.y, atan2(-velocity.x, -velocity.z), turn_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)
		
	# rotate mesh pivot to face direction
	#mesh_pivot.rotation.y = lerp_angle(mesh_pivot.rotation.y, atan2(-velocity.x, -velocity.z), turn_speed * delta)

		
	#TODO: Put state machine stuff here
	move_direction = direction

	handle_camera(delta)
	move_and_slide()

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

func compute_move_direction() -> Vector3:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (cam_yaw_pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	return direction
	
	
func transition_to_state(state: String) -> void:
	if states.has(state):
		states[current_state].exit(self)
		current_state = state
		states[current_state].enter(self)
	else:
		push_error("State " + state + " does not exist in the state machine.")