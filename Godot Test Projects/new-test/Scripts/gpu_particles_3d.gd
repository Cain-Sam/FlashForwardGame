extends GPUParticles3D



func _ready() -> void:
	add_to_group("global_kick_events")
	emitting = false 

func trigger_kick_effect() -> void:
	emitting = true
