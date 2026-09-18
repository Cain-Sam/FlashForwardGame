extends Node3D


const SPEED = 40

@onready var csg_mesh_3d_2: CSGMesh3D = $CSGMesh3D2
@onready var bullet_raycast: RayCast3D = $bullet_raycast
@onready var omni_light: OmniLight3D = $OmniLight

var stuck := false
var physics_groups = ["kickable", "collidable"]

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
	var hit_object = bullet_raycast.get_collider()
	
	global_position = collision
	if coll_normal.abs() != Vector3.UP:
		look_at(collision + coll_normal, Vector3.UP)
	
		var collider = bullet_raycast.get_collider()
		for i in physics_groups:
			if collider.is_in_group(i) or collider.get_parent().is_in_group(i):
				merge_bullet(hit_object)

func merge_bullet(hit_object):
	bullet_raycast.queue_free()
	 
	if hit_object.has_method("_manual_on_body_entered"):
		hit_object._manual_on_body_entered(self)
		 
	csg_mesh_3d_2.use_collision = false
	
	for child in get_children():
		if child is CollisionShape3D or child is CollisionObject3D:
			child.queue_free()

	if hit_object and hit_object is Node:
		reparent(hit_object, true)
