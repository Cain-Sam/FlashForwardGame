extends SoftBody3D
@onready var activate: AudioStreamPlayer = $Enchant

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _manual_on_body_entered(body: Node3D) -> void:
	if body.is_in_group("bullet"):
		changeColor(ColorList.color_list[ColorList.colorindex].darkened(ColorList.darken_list[ColorList.darkenindex]))
		activate.play()
		body.queue_free()
		
func changeColor(color):
	var unique_material = self.material_override.duplicate()
	self.material_override = unique_material;
	self.material_override.albedo_color = color;
	self.material_override.emission = color;
