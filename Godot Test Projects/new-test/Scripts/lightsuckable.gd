extends RigidBody3D
@export var ON: bool = true
@export var currentPower: float = 1
@export var maxPower: float = 1
@export var bulbEmission = 15
@export var lightEnergy: float = 5 
@export var lightRange = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var bulb = find_child("Bulb")
	var light = find_child("Light")
	light.omni_range = lightRange
	if ON:
		bulb.material_override.emission_energy_multiplier = bulbEmission
		light.light_energy = lightEnergy
	else:
		bulb.material_override.emission_energy_multiplier = 0.5
		light.light_energy = 0
		currentPower = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func suckLight():
	# if there is still power in the light, suck 1 power from it
	if currentPower > 0:
		currentPower -= 1
		
		# Please literally name your mesh "Bulb" and your light "Light" See lamp scene for a blueprint
		var bulb = find_child("Bulb")
		var light = find_child("Light")
		
		# If this brings power down to 0, turn off light
		if currentPower == 0:
			bulb.material_override.emission_energy_multiplier = 0.5
			light.light_energy = 0
			
		# Otherwise just dim the light
		else:
			bulb.material_override.emission_energy_multiplier = (bulbEmission/2) * (currentPower/maxPower)
			light.light_energy = (lightEnergy/2) * (currentPower/maxPower)
		return true
	else:
		return false

func bulletHit(body: Node3D) -> bool:
	if body.is_in_group("bullet"):
		body.queue_free()
		
		var bulb = find_child("Bulb")
		var light = find_child("Light")
		
		changeLightColor(bulb, light)
		
		# If we are not at max power, power up the bulb
		if currentPower < maxPower && !body.is_in_group("paint"):
			currentPower += 1
			
			# If this brings light to max power, fully light bulb
			if currentPower == maxPower:
				bulb.material_override.emission_energy_multiplier = bulbEmission
				light.light_energy = lightEnergy
			
			# Otherwise just turn light up a bit
			else:
				bulb.material_override.emission_energy_multiplier = (bulbEmission/2) * (currentPower/maxPower)
				light.light_energy = (lightEnergy/2) * (currentPower/maxPower)
			return true
		# If we shot bullet at already full light, return the ammo
		if !body.is_in_group("paint"):
			GlobalVariables.lightAmmo += 1
	return false

func changeLightColor(bulb, light):
	light.light_color = GlobalVariables.get_color().lightened(0.3)
	bulb.material_override.emission = GlobalVariables.get_color().lightened(0.3)
