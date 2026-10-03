extends Node3D

const SPEED = 45

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var bullet_raycast: RayCast3D = $bullet_raycast
@onready var collision_shape_3d: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var static_body_3d: StaticBody3D = $StaticBody3D

var stuck = false

func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if stuck:
		return
	
	if bullet_raycast.is_colliding():
		if is_instance_valid(bullet_raycast.get_collider()) && !bullet_raycast.get_collider().is_in_group("player") && !bullet_raycast.get_collider().is_in_group("bullet"):
			flattenPaint()
			stick()
	else:
		position += transform.basis * Vector3(0, 0, -SPEED) * delta
		
func stick() -> void:
	stuck = true
	var collision = bullet_raycast.get_collision_point()
	var coll_normal = bullet_raycast.get_collision_normal()
	var hit_object = bullet_raycast.get_collider()
	global_position = collision
	paintLieFlat(coll_normal)
	checkForObjectReaction(hit_object)
	removeCollision()
	mergeWithObject(hit_object)
	simplifyPaint()

func paintLieFlat(coll_normal):
	var up_dir = Vector3.UP if abs(coll_normal.dot(Vector3.UP)) < 0.99 else Vector3.RIGHT
	look_at(global_position + coll_normal, up_dir)

func checkForObjectReaction(hit_object):
	var collider = bullet_raycast.get_collider()
	bullet_raycast.queue_free()
	if collider.has_method("bulletHit"):
		hit_object.bulletHit(self)

func removeCollision():
	for child in get_children():
		if child is CollisionShape3D or child is CollisionObject3D:
			child.queue_free()
			
func mergeWithObject(hit_object):
	if hit_object and hit_object is Node:
		reparent(hit_object, true)

func flattenPaint():
	mesh_instance_3d.scale.x = 0.4
	mesh_instance_3d.scale.y = 0.4
	mesh_instance_3d.scale.z = 0.05
	mesh_instance_3d.visible = true

func simplifyPaint():
	static_body_3d.queue_free()
	bullet_raycast.queue_free()
