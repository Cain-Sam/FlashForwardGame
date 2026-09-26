extends StaticBody3D
@export var currentPower: int = 1
@export var maxPower: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func suckLight():

	self.get_parent().queue_free()
	return true
