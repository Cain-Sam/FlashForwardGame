extends SoftBody3D
@onready var activate: AudioStreamPlayer = $Enchant

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _manual_on_body_entered(body: Node3D) -> bool:
	if body.is_in_group("bullet"):
		changeColor(ColorList.get_color())
		body.queue_free()
	return false
		
func changeColor(color):
	var unique_material = self.material_override.duplicate()
	self.material_override = unique_material;
	if self.material_override.albedo_color != ColorList.get_color():
		activate.play()
	self.material_override.albedo_color = color;
	self.material_override.emission = color;
