extends AudioStreamPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$".".stream = load("res://Audio/The Paperstud Savage Young Taterbug.mp3")
	$".".play()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
