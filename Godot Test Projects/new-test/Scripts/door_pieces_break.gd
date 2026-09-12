extends Node3D

var direction: Vector3 = Vector3.ZERO
var intensity: float = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for pieces:RigidBody3D in self.get_children():
		pieces.apply_impulse( direction * intensity, self.global_position );
		
	await get_tree().create_timer(5).timeout; 
	queue_free();
