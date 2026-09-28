extends SoftBody3D
@onready var activate: AudioStreamPlayer = $Enchant

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func bulletHit(body: Node3D) -> void:
	if body.is_in_group("bullet"):
		changeColor(GlobalVariables.get_color())
		body.queue_free()
		GlobalVariables.lightAmmo += 1
		
func changeColor(color):
	# Making a new unique copy of the softbody material to avoid changing every softbody of the same type
	var unique_material = self.material_override.duplicate()
	self.material_override = unique_material;
	if self.material_override.albedo_color != GlobalVariables.get_color():
		activate.play()
	self.material_override.albedo_color = color;
	self.material_override.emission = color;
