extends AudioStreamPlayer3D



func _ready() -> void:
	add_to_group("global_kick_events")

func trigger_kick_effect() -> void:
	if not playing:
		play()
