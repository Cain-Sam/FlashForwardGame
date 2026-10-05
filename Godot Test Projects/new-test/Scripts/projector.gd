extends SpotLight3D




func _ready() -> void:
	var viewport = $"../SubViewport"
	print(viewport)
	light_projector = viewport.get_texture()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
