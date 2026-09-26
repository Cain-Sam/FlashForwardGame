extends RigidBody3D
@export var ON: bool = true
@export var currentPower: float = 1
@export var maxPower: float = 1
@export var bulbEmission = 50
@export var lightEnergy = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var bulb = find_child("Bulb")
	var light = find_child("Light")
	if ON:
		bulb.material_override.emission_energy_multiplier = bulbEmission
		light.light_energy = lightEnergy
	else:
		bulb.material_override.emission_energy_multiplier = 0
		light.light_energy = 0
		currentPower = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func suckLight():
	if currentPower > 0:
		currentPower -= 1
		var bulb = find_child("Bulb")
		var light = find_child("Light")
		if currentPower == 0:
			bulb.material_override.emission_energy_multiplier = 0
			light.light_energy = 0
		else:
			bulb.material_override.emission_energy_multiplier = (bulbEmission/2) * (currentPower/maxPower)
			light.light_energy = (lightEnergy/2) * (currentPower/maxPower)
		return true
	else:
		return false

func _manual_on_body_entered(body: Node3D) -> bool:
	if body.is_in_group("bullet"):
		body.queue_free()
		if currentPower < maxPower:
			currentPower += 1
			var bulb = find_child("Bulb")
			var light = find_child("Light")
			light.light_color = ColorList.get_color()
			bulb.material_override.emission = ColorList.get_color()
			if currentPower == maxPower:
				bulb.material_override.emission_energy_multiplier = bulbEmission
				light.light_energy = lightEnergy
			else:
				bulb.material_override.emission_energy_multiplier = (bulbEmission/2) * (currentPower/maxPower)
				light.light_energy = (lightEnergy/2) * (currentPower/maxPower)
			return true
	return false
		
