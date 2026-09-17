extends RigidBody3D
@export var directionXOffset: float = 0
@export var directionYOffset: float = 0
@export var directionZOffset: float = 0
@export var intensityOffset: float = 0
var velocity_last_frame: Vector3 = Vector3.ZERO
@export var directionXOffset: float = 0
@export var directionYOffset: float = 1
@export var directionZOffset: float = 0
@export var intensityOffset: float = 10

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
		
