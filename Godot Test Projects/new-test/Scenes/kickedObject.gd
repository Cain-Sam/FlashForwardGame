extends RigidBody3D

func kicked(direction, intensity):
	direction.y += 1
	intensity += 10
	self.apply_impulse( direction * intensity, self.global_position )
