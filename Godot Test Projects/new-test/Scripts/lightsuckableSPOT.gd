extends RigidBody3D
@export var ON: bool = true
@export var currentPower: float = 1
@export var maxPower: float = 1
@export var bulbEmission: float = 15
@export var lightEnergy: float = 5 
@export var lightRange = 100
@export_range(0, 180, 0.1, "suffix:°") var radius: float = 45.0
var bulb = find_child("Bulb")
var light = find_child("Light")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bulb = find_child("Bulb")
	light = find_child("Light")
	light.spot_range = lightRange
	light.spot_angle = radius
	if ON && currentPower > 0:
		bulb.material_override.emission_energy_multiplier = bulbEmission
		light.light_energy = lightEnergy
	else:
		bulb.material_override.emission_energy_multiplier = 0.5
		light.light_energy = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !ON:
		bulb.material_override.emission_energy_multiplier = 0.5
		light.light_energy = 0
	else:
		if currentPower == 0:
			bulb.material_override.emission_energy_multiplier = 0.5
			light.light_energy = 0
		
		elif currentPower == maxPower:
			bulb.material_override.emission_energy_multiplier = bulbEmission
			light.light_energy = lightEnergy
		
		else:
			bulb.material_override.emission_energy_multiplier = (bulbEmission/2) * (currentPower/maxPower)
			light.light_energy = (lightEnergy/2) * (currentPower/maxPower)
			
func suckLight():
	# if there is still power in the light, suck 1 power from it
	if currentPower > 0:
		currentPower -= 1
		
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
		
		changeLightColor()
		
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

func changeLightColor():
	light.light_color = GlobalVariables.get_color().lightened(0.3)
	bulb.material_override.emission = GlobalVariables.get_color().lightened(0.3)
