extends Node3D

const SPEED = 40
@onready var csg_mesh_3d_2: SoftBody3D = $CSGMesh3D2
@onready var bullet_raycast: RayCast3D = $bullet_raycast
@onready var omni_light: OmniLight3D = $OmniLight

var stuck := false


func _ready() -> void:
	bullet_raycast.add_exception_rid(csg_mesh_3d_2.get_physics_rid())
	
	for i in range(csg_mesh_3d_2.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size()):
		if csg_mesh_3d_2.is_point_pinned(i):
			csg_mesh_3d_2.set_point_pinned(i, true, csg_mesh_3d_2.get_path_to(self))


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
