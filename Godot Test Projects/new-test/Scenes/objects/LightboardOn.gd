extends StaticBody3D
var power: bool = false
@onready var stageLights: Node3D = $"../../Lights/StageLights"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		self.get_child(0).material_override.albedo_color = Color(255, 0, 0).darkened(0.5)
		self.get_child(0).material_override.emission = Color(255, 0, 0).darkened(0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func kicked(_direction, _intensity):
	power = !power
	for group in stageLights.get_children():
		for lightObject in group.get_children():
			lightObject.ON = !lightObject.ON
	
	if !power:
		self.get_child(0).material_override.albedo_color = Color(255, 0, 0).darkened(0.5)
		self.get_child(0).material_override.emission = Color(255, 0, 0).darkened(0.5)
		for child in self.get_parent().get_children():
			if child is Sprite3D:
				child.visible = false
	else:
		self.get_child(0).material_override.albedo_color = Color(0, 255, 0).darkened(0.5)
		self.get_child(0).material_override.emission = Color(0, 255, 0).darkened(0.5)
		for child in self.get_parent().get_children():
			if child is Sprite3D:
				child.visible = true
