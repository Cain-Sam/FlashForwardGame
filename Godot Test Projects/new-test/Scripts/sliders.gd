extends StaticBody3D
@onready var stageLights: Node3D = $"../../../../Lights/StageLights"
@export var lightGroup = ""
@export var level = 1
@export var lightIntensity = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tempCount = level
	while tempCount > 0:
		self.position.z -= 0.1
		tempCount -= 1
		for uniqueLight in stageLights.find_child(lightGroup).get_children():
				uniqueLight.lightEnergy += lightIntensity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func bulletHit(body: Node3D) -> void:
	if body.is_in_group("bullet"):
		changeColor(GlobalVariables.get_color())
		body.queue_free()
		if !body.is_in_group("paint"):
			GlobalVariables.lightAmmo += 1
		
func changeColor(color):
	# Making a new unique copy of the softbody material to avoid changing every softbody of the same type
	var unique_material = self.get_child(0).material_override.duplicate()
	self.get_child(0).material_override = unique_material;
	self.get_child(0).material_override.albedo_color = color;
	self.get_child(0).material_override.emission = color;
	for uniqueLight in stageLights.find_child(lightGroup).get_children():
		var bulb = uniqueLight.find_child("Bulb")
		var light = uniqueLight.find_child("Light")
		light.light_color = GlobalVariables.get_color().lightened(0.3)
		bulb.material_override.emission = GlobalVariables.get_color().lightened(0.3)
		
func kicked(direction, intensity):
	if direction.x * intensity > 0:
		if level < 7:
			level += 1
			self.position.z -= 0.1
			for uniqueLight in stageLights.find_child(lightGroup).get_children():
				uniqueLight.lightEnergy += lightIntensity
	else:
		if level > 0:
			level -= 1
			self.position.z += 0.1
			for uniqueLight in stageLights.find_child(lightGroup).get_children():
				uniqueLight.lightEnergy -= lightIntensity
					
					
		
