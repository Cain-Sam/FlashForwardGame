extends CharacterBody3D

#Player Nodes

@onready var head: Node3D = $Head
@onready var standing_collision_shape: CollisionShape3D = $standing_collision_shape
@onready var crouching_collision_shape: CollisionShape3D = $crouching_collision_shape
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var camera: Camera3D = $Head/Camera3D
@onready var view_model_camera: Camera3D = $Head/Camera3D/SubViewportContainer/SubViewport/view_model_camera
@export var myhead_4: Node3D

#Movement Vars

@export var current_speed = 5.0
@export var jump_velocity = 4.5
@export var walking_speed = 5.0
@export var sprinting_speed = 8.0
@export var crouching_speed = 3.0
var crouching_depth = -0.1
@export var lerp_speed = 10.0

#Input Variables



var direction = Vector3.ZERO
const mouse_sens = 0.25

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Head/Camera3D/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-78),deg_to_rad(85))
		view_model_camera.sway(Vector2(event.relative.x,event.relative.y))
	
func _physics_process(delta):
	$Head/Camera3D/SubViewportContainer/SubViewport/view_model_camera.global_transform = camera.global_transform
	
	#Handle Movement State
	
	#Crouching
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y,0.391 + crouching_depth,delta*lerp_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
	elif !ray_cast_3d.is_colliding(): 
		#Standing
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		head.position.y = lerp(head.position.y,0.391,delta*lerp_speed)
		if Input.is_action_pressed("sprint"):
			#Sprinting
			current_speed = sprinting_speed
		else: 
			#Walking
			current_speed = walking_speed
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
