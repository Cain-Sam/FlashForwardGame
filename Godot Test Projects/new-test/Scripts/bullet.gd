extends Node3D

const SPEED = 40
@onready var csg_mesh_3d_2: SoftBody3D = $CSGMesh3D2
@onready var bullet_raycast: RayCast3D = $bullet_raycast
@onready var omni_light: OmniLight3D = $OmniLight

var stuck := false
var stuck_collider: Node3D = null
var pinned_point_indices: Array[int] = []
var pinned_local_offsets: Array[Vector3] = []


func _ready() -> void:
	bullet_raycast.add_exception_rid(csg_mesh_3d_2.get_physics_rid())

	for i in range(csg_mesh_3d_2.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX].size()):
		if csg_mesh_3d_2.is_point_pinned(i):
			csg_mesh_3d_2.set_point_pinned(i, true, csg_mesh_3d_2.get_path_to(self))
			pinned_point_indices.append(i)


func _process(delta):
	if stuck:
		return

	if bullet_raycast.is_colliding():
		_stick()
	else:
		position += transform.basis * Vector3(0, 0, -SPEED) * delta


func _physics_process(_delta: float) -> void:
	if not stuck or stuck_collider == null:
		return

	var body_rid := csg_mesh_3d_2.get_physics_rid()
	var collider_transform := stuck_collider.global_transform

	for idx in range(pinned_point_indices.size()):
		var i: int = pinned_point_indices[idx]
		var target: Vector3 = collider_transform * pinned_local_offsets[idx]
		PhysicsServer3D.soft_body_move_point(body_rid, i, target)


func _stick() -> void:
	stuck = true

	var collision = bullet_raycast.get_collision_point()
	var coll_normal = bullet_raycast.get_collision_normal()
	var collider = bullet_raycast.get_collider()

	global_position = collision
	if coll_normal.abs() != Vector3.UP:
		look_at(collision + coll_normal, Vector3.UP)

	if collider is Node3D:
		_pin_points_to_collider(collider, collision, coll_normal)
	else:
		push_warning("Bullet stuck to a non-Node3D collider (%s); can't attach." % str(collider))


func _pin_points_to_collider(collider: Node3D, collision_point: Vector3, coll_normal: Vector3) -> void:
	stuck_collider = collider


	for i in pinned_point_indices:
		csg_mesh_3d_2.set_point_pinned(i, true)

	var inverse_collider_transform := collider.global_transform.affine_inverse()

	for i in pinned_point_indices:
		var point_pos: Vector3 = csg_mesh_3d_2.get_point_transform(i)
		var projected := point_pos - coll_normal * (point_pos - collision_point).dot(coll_normal)
		pinned_local_offsets.append(inverse_collider_transform * projected)
