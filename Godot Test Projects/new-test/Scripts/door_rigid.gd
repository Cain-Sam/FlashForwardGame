extends StaticBody3D
const DOOR_PIECES_MODIFIER = preload("uid://cdeodg3s1run2")

func _ready():
	EventBus.kicked.connect(kicked)

func kicked(direction, intensity, collider):
	if collider == self:
		var broken_model_inst = DOOR_PIECES_MODIFIER.instantiate();
		broken_model_inst.direction = direction
		broken_model_inst.intensity = intensity	
		get_parent().add_child(broken_model_inst)
		broken_model_inst.global_transform = self.global_transform;
		self.queue_free();
