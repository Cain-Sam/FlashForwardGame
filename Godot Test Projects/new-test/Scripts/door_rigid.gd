extends RigidBody3D
const DOOR_PIECES_MODIFIER = preload("uid://cdeodg3s1run2")
@export var intensityBreakThresh = 2.2
@export var kickBreakable: bool = true

@onready var door_break: AudioStreamPlayer3D = %door_break_sound_effects
@onready var door_mesh: MeshInstance3D = $DoorMesh


func kicked(direction, intensity):
	if kickBreakable:
		breakDoor(direction, intensity);

func collided(direction, intensity):
	if intensity > intensityBreakThresh:
		breakDoor(direction, intensity);
		

func breakDoor(direction, intensity):
	var broken_model_inst = DOOR_PIECES_MODIFIER.instantiate();
	broken_model_inst.direction = direction
	broken_model_inst.intensity = intensity	
	get_parent().add_child(broken_model_inst)
	broken_model_inst.global_transform = self.global_transform;
	for child in broken_model_inst.find_children("*", "MeshInstance3D"):
		if self.door_mesh.material_override != null:
			child.material_override = self.door_mesh.material_override
	door_break.play()
	self.queue_free();
	
