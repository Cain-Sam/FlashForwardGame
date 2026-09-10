extends CharacterBody3D


@export var current_speed = 5.0
@export var jump_velocity = 4.5
@export var walking_speed = 5.0
@export var sprinting_speed = 8.0
@export var crouching_speed = 3.0

func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("sprint"):
		current_speed = sprinting_speed
	else: 
		current_speed = walking_speed
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
