extends Node3D


const SPEED = 40

@onready var csg_mesh_3d_2: CSGMesh3D = $CSGMesh3D2
@onready var bullet_raycast: RayCast3D = $bullet_raycast
@onready var omni_light: OmniLight3D = $OmniLight

var stuck := false

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if stuck:
		return
	
	if bullet_raycast.is_colliding():
		_stick()
	else:
		position += transform.basis * Vector3(0, 0, -SPEED) * delta
		
func _stick() -> void:
	stuck = true
	
	var collision = bullet_raycast.get_collision_point()
	var coll_normal = bullet_raycast.get_collision_normal()
	
	global_position = collision
	
	if coll_normal.abs() != Vector3.UP:
		look_at(collision + coll_normal, Vector3.UP)

			
