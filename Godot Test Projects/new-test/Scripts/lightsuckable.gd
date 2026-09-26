extends RigidBody3D
@export var ON: bool = true
@export var currentPower: int = 1
@export var maxPower: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func suckLight():
	if currentPower > 0:
		currentPower -= 1
		if currentPower == 0:
			var bulb = find_child("Bulb")
			var light = find_child("Light")
			bulb.material_override.emission = 0
			light.light_energy = 0
		return true
	else:
		return false
