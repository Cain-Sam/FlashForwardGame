extends MeshInstance3D
@export var lightGroup = ""
@export var lightName = ""
@onready var stageLights: Node3D = $"../../../../Lights/StageLights"
var light
var level = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	light = stageLights.find_child(lightGroup).find_child(lightName)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !light.ON:
		self.material_override.albedo_color = Color(0, 0, 0)
	elif light.currentPower == 0:
		self.material_override.albedo_color = Color(255, 0, 0).darkened(0.5)
	elif light.currentPower == light.maxPower:
		self.material_override.albedo_color = Color(0, 255, 0).darkened(0.5)
	else:
		self.material_override.albedo_color = Color(255, 255, 0).darkened(0.5)
