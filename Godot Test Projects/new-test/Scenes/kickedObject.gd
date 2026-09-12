extends RigidBody3D
var velocity_last_frame: Vector3 = Vector3.ZERO

func kicked(direction, intensity):
	direction.y += 1
	intensity += 10
	self.apply_impulse( direction * intensity, self.global_position )
	
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var contact_count = state.get_contact_count()
	
	for i in range(contact_count):
		var total_impulse := Vector3.ZERO
		var impulse := state.get_contact_impulse(i)
		total_impulse += impulse
		
		var impact_strength := total_impulse.length()
		
		var hit_object = state.get_contact_collider_object(i)
		var hit_from_direction = state.get_contact_local_normal(i)
		
		if hit_object && state.get_contact_collider_object(i).has_method("collided") && total_impulse.length() > 0.2:		
			state.get_contact_collider_object(i).collided(hit_from_direction, total_impulse.length() + 2)
			print (str(hit_from_direction))
		
