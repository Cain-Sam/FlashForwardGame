extends SpotLight3D



@export var fade_duration: float = 5.0  
@export var max_energy: float = 5.0       

func _ready() -> void:
	add_to_group("global_kick_events")
	visible = true
	light_energy = 0.0 

func trigger_kick_effect() -> void:
	
	var tween = create_tween()
	
	tween.tween_property(self, "light_energy", max_energy, fade_duration)
