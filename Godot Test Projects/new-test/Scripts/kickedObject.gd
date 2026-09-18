extends RigidBody3D
@export var directionXOffset: float = 0
@export var directionYOffset: float = 0
@export var directionZOffset: float = 0
@export var intensityOffset: float = 0
var velocity_last_frame: Vector3 = Vector3.ZERO

func kicked(direction, intensity):
	direction.x += directionXOffset
	direction.y += directionYOffset
	direction.z += directionZOffset
	intensity += intensityOffset
	self.apply_impulse( direction * intensity, self.global_position )
	
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var contact_count = state.get_contact_count()
	
	for i in range(contact_count):
		var total_impulse := Vector3.ZERO
		var impulse := state.get_contact_impulse(i)
		total_impulse += impulse
		
		var impact_strength := total_impulse.length()
		
		var hit_object = state.get_contact_collider_object(i)
		var global_normal = state.get_contact_local_normal(i)
		var hit_from_direction = global_transform.basis * global_normal
		
		if hit_object && state.get_contact_collider_object(i).has_method("collided"):		
			state.get_contact_collider_object(i).collided(hit_from_direction, total_impulse.length() + 2)
		
func _physics_process(delta: float) -> void:
	if linear_velocity.length_squared() < 0.5:
		return
	var next_position = global_position + (linear_velocity * delta)
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, next_position)
	query.collision_mask = collision_mask 
	var result = space_state.intersect_ray(query)
	if result and result.collider is SoftBody3D:
		global_position = result.position - (linear_velocity.normalized() * 0.05)
		linear_velocity = linear_velocity * 0.15
		linear_velocity.y -= 2.0 
